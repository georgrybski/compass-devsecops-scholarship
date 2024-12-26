#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Checks the Nginx service status and appends JSON log entries to:
  /var/log/nginx_status/online.log   or
  /var/log/nginx_status/offline.log

Options:
  -v, --verbose  Show verbose internal command logs
  -h, --help     Show this help message
EOF
  exit 1
}

GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[0;34m"
RESET="\033[0m"

info()    { echo -e "${GREEN}[INFO]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
verbose() {
  [[ "$VERBOSE" == true ]] && while IFS= read -r line; do
    echo -e "${BLUE}[VERBOSE]${RESET} $line"
  done
}

yell() { error "$0: $*" >&2; }
die() {
  local exit_code=${2:-1}
  yell "$1"
  exit "$exit_code"
}
try() { "$@" || die "cannot $*"; }

parse_arguments() {
  VERBOSE=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--verbose) VERBOSE=true ;;
      -h|--help) usage ;;
      *) die "Unknown option: $1" ;;
    esac
    shift
  done
}

ensure_sudo() {
  "$EUID" -eq 0 && return 0
  sudo -n true 2>/dev/null && return 0
  sudo -v && return 0
  die "sudo privileges are required to run this script."
}

detect_package_manager() {
  for pm in apt dnf; do
    command -v "$pm" &>/dev/null || continue
    echo "$pm"
    return 0
  done
  return 1
}

map_package_name() {
  local cmd="$1"
  local pm="$2"

  case "$pm" in
    apt)
      case "$cmd" in
        jq) echo "jq" ;;
        ec2-metadata) echo "cloud-utils" ;;
        *) return 1 ;;
      esac
       ;;
    dnf)
      case "$cmd" in
        jq) echo "jq" ;;
        ec2-metadata) echo "ec2-utils" ;;
        *) return 1 ;;
      esac
       ;;
    *) return 1 ;;
  esac
  return 0
}

install_package() {
  local pkg="$1" pm="$2"

  verbose "Using $pm to install '$pkg'"
  case "$pm" in
    apt) {
      try apt-get update -y
      try apt-get install -y "$pkg"
    } ;;
    dnf) try dnf install -y "$pkg" ;;
  esac
  return 0
}

ensure_command_available() {
  local cmd="$1"

  command -v "$cmd" &>/dev/null && {
    verbose "'$cmd' is already installed."
    return 0
  }

  local pm
  pm=$(detect_package_manager) || return 1

  local pkg
  pkg=$(map_package_name "$cmd" "$pm") || return 1

  info "'$cmd' is not installed. Installing '$pkg'..."

  install_package "$pkg" "$pm" || return 1

  command -v "$cmd" || return 1

  info "'$cmd' installation completed."
  return 0
}

get_aws_instance_metadata() {
  local metadata
  metadata=$(ec2-metadata -i -R 2>/dev/null || echo "")

  INSTANCE_ID="localhost"
  REGION="unknown"

  while read -r line; do
    case "$line" in
      instance-id*) INSTANCE_ID=$(echo "$line" | awk '{print $2}') ;;
      region*) REGION=$(echo "$line" | awk '{print $2}') ;;
    esac
  done <<< "$metadata"
}

log_json() {
  local status="$1" message="$2" log_file
  log_file="$([[ "$status" == "online" ]] && echo "$ONLINE_LOG" || echo "$OFFLINE_LOG")"

  jq -nc \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg svc "nginx" \
    --arg st "$status" \
    --arg msg "$message" \
    --arg iid "$INSTANCE_ID" \
    --arg rgn "$REGION" \
    '{
      timestamp: $ts,
      service: $svc,
      status: $st,
      message: $msg,
      instance_id: $iid,
      region: $rgn
    }' \
     | tee -a "$log_file" \
     | verbose \
     || die "Could not log JSON with jq and tee"
}

check_status_systemctl() {
  verbose "Using 'systemctl' to check Nginx status."

  local status="offline" message="Nginx is not running" status_output
  status_output=$(systemctl is-active nginx || echo "")

  [[ "$status_output" == "active" ]] && {
    status="online"
    message="Nginx is running."
  }

  log_json "$status" "$message"
  return 0
}

check_status_service() {
  verbose "Using 'service' command to check Nginx status."
  local status="offline" message="Nginx is not running." status_output
  status_output=$(service nginx status)

  echo "$status_output" | grep -qi "running" && {
    status="online" message="Nginx is running."
  }

  log_json "$status" "$message"
  return 0
}

check_nginx_status() {
  verbose "Checking Nginx status..."
  command -v systemctl &>/dev/null && check_status_systemctl && return 0
  command -v service &>/dev/null && check_status_service && return 0
  die "Neither 'systemctl' nor 'service' command is available."
}

main() {
  ensure_sudo

  parse_arguments "$@"

  for cmd in "jq" "ec2-metadata"; do
    ensure_command_available "$cmd" || die "Essential command '$cmd' could not be installed."
  done

  get_aws_instance_metadata

  LOG_DIR="/var/log/nginx_status"
  ONLINE_LOG="$LOG_DIR/online.log"
  OFFLINE_LOG="$LOG_DIR/offline.log"

  info "Ensuring log directory: $LOG_DIR"
  try mkdir -p "$LOG_DIR"
  try touch "$ONLINE_LOG" "$OFFLINE_LOG"
  try chmod 666 "$ONLINE_LOG" "$OFFLINE_LOG"

  check_nginx_status
}

main "$@"