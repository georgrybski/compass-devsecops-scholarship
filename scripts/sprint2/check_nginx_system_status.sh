#!/usr/bin/env bash
set -e

# =================================
# Nginx System Status Checker
# =================================
# Checks the systemd/service status of Nginx and logs JSON results to:
#   /var/log/nginx_status/online.log   (if online)
#   /var/log/nginx_status/offline.log  (if offline)

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

info()    { echo -e "${GREEN}[INFO]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
verbose() { [[ "$VERBOSE" == true ]] && echo -e "[VERBOSE] $*"; }

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

parse_arguments() {
  VERBOSE=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--verbose)
        VERBOSE=true
        ;;
      -h|--help)
        usage
        ;;
      *)
        error "Unknown option: $1"
        usage
        ;;
    esac
    shift
  done
}

detect_package_manager() {
  for pm in apt dnf; do
    if command -v "$pm" &>/dev/null; then
      echo "$pm"
      return
    fi
  done
  echo "unsupported"
}

install_package() {
  local package="$1"
  local pm
  pm=$(detect_package_manager)

  case "$pm" in
    apt)
      verbose "Using apt to install $package."
      sudo apt-get update -y
      sudo apt-get install -y "$package"
      ;;
    dnf)
      verbose "Using dnf to install $package."
      sudo dnf install -y "$package"
      ;;
    *)
      error "Unsupported package manager. Cannot install $package."
      exit 1
      ;;
  esac
}

ensure_command_available() {
  local cmd="$1"
  local pkg="$2"
  if ! command -v "$cmd" &>/dev/null; then
    info "'$cmd' is not installed. Installing '$pkg'..."
    install_package "$pkg"
    if ! command -v "$cmd" &>/dev/null; then
      error "Failed to install '$cmd'."
      exit 1
    fi
    info "'$cmd' installation completed."
  else
    verbose "'$cmd' is already installed."
  fi
}

get_aws_instance_metadata() {
  local metadata
  metadata=$(ec2-metadata -i -R 2>/dev/null || echo "")

  INSTANCE_ID="localhost"
  REGION="unknown"

  while read -r line; do
    case "$line" in
      instance-id*) INSTANCE_ID=$(echo "$line" | awk '{print $2}') ;;
      region*) REGION=$(echo "$line" | awk '{print $2}' | sed 's/[a-z]$//') ;;
    esac
  done <<< "$metadata"
}

log_json() {
  local status="$1"
  local message="$2"
  local log_file
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
    }' | sudo tee -a "$log_file" >/dev/null
}

check_status_systemctl() {
  verbose "Using 'systemctl' to check Nginx status."
  local status_output
  status_output=$(systemctl is-active nginx)

  if [[ "$status_output" == "active" ]]; then
    log_json "online" "Nginx is running."
    exit 0
  fi

  log_json "offline" "Nginx is not running."
  exit 1
}

check_status_service() {
  verbose "Using 'service' command to check Nginx status."
  local status_output
  status_output=$(service nginx status)

  if echo "$status_output" | grep -qi "running"; then
    log_json "online" "Nginx is running."
    exit 0
  fi

  log_json "offline" "Nginx is not running."
  exit 1
}

main() {
  parse_arguments "$@"

  ensure_command_available "jq" "jq"
  ensure_command_available "ec2-metadata" "ec2-metadata"

  get_aws_instance_metadata

  LOG_DIR="/var/log/nginx_status"
  ONLINE_LOG="$LOG_DIR/online.log"
  OFFLINE_LOG="$LOG_DIR/offline.log"

  info "Ensuring log directory: $LOG_DIR"
  sudo mkdir -p "$LOG_DIR"
  sudo touch "$ONLINE_LOG" "$OFFLINE_LOG"
  sudo chmod 666 "$ONLINE_LOG" "$OFFLINE_LOG"

  verbose "Checking Nginx status..."

  if command -v systemctl &>/dev/null; then
    check_status_systemctl
  elif command -v service &>/dev/null; then
    check_status_service
  else
    error "Neither 'systemctl' nor 'service' command is available."
    log_json "offline" "No valid command to check Nginx status."
    exit 1
  fi
}

main "$@"