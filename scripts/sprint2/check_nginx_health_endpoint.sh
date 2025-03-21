#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [OPTIONS] <BASE_URL>

Checks the /health endpoint of <BASE_URL> and appends JSON results to:
  /var/log/nginx_health_endpoint/online.log
  /var/log/nginx_health_endpoint/offline.log

Example:
  $0 http://12.34.56.78  # An external IP or domain

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
  [[ "$VERBOSE" != true ]] && return 0
  if [[ -p /dev/stdin ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      echo -e "${BLUE}[VERBOSE]${RESET} $line"
    done
  elif [[ -n "$*" ]]; then
    echo -e "${BLUE}[VERBOSE]${RESET} $*"
  fi
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
      -*) die "Unknown option: $1" ;;
      *) break ;;
    esac
    shift
  done

  [[ $# -eq 0 ]] && die "BASE_URL is required."
  [[ $# -gt 1 ]] && die "Multiple BASE_URLs provided."

  BASE_URL="$1"
}

ensure_sudo() { sudo -n true 2>/dev/null || die "sudo privileges are required to run this script."; }

detect_package_manager() {
  for pm in apt dnf; do
    command -v "$pm" &>/dev/null || continue
    echo "$pm"
    return 0
  done
  return 1
}

map_package_name() {
  local cmd="$1" pm="$2"

  case "$pm" in
    apt)
      case "$cmd" in
        jq) echo "jq" ;;
        curl) echo "curl" ;;
        *) return 1 ;;
      esac
      ;;
    dnf)
      case "$cmd" in
        jq) echo "jq" ;;
        curl) echo "curl" ;;
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
    apt)
      try apt-get update -y
      try apt-get install -y "$pkg"
      ;;
    dnf)
      try dnf install -y "$pkg"
      ;;
  esac
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

log_json() {
  local status="$1" message="$2" log_file http_code_json
  log_file="$([[ "$status" == "online" ]] && echo "$ONLINE_LOG" || echo "$OFFLINE_LOG")"
  [[ -z "${HTTP_CODE:-}" ]] && http_code_json="null" || http_code_json="$HTTP_CODE"

  jq -nc \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg st "$status" \
    --arg msg "$message" \
    --arg turl "$BASE_URL" \
    --argjson hc "$http_code_json" \
    '{
      timestamp: $ts,
      status: $st,
      message: $msg,
      http_code: $hc,
      target_url: $turl
    }' \
    | tee -a "$log_file" \
    | verbose \
    || die "Could not log JSON with jq and tee"
}

perform_health_check() {
  local address="$1/health" curl_exit_code=0 status message
  verbose "Checking $address ..."
  HTTP_CODE="$(curl -s -o /dev/null -w "%{http_code}" "$address")" || curl_exit_code=$?

  [[ $curl_exit_code -ne 0 ]] && {
    status="offline"
    message="Curl failed with exit code $curl_exit_code while accessing $address."
    log_json "$status" "$message"
    return 0
  }

  [[ -z "${HTTP_CODE:-}" ]] && {
    status="offline"
    message="Curl succeeded but no HTTP code was captured. This is unexpected."
    log_json "$status" "$message"
    return 0
  }

  status="online"
  message="Nginx health endpoint returned code $HTTP_CODE."
  log_json "$status" "$message"
  return 0
}

main() {
  ensure_sudo
  parse_arguments "$@"

  for cmd in jq curl; do
    ensure_command_available "$cmd" || die "Essential command '$cmd' could not be installed."
  done

  LOG_DIR="/var/log/nginx_health_endpoint"
  ONLINE_LOG="$LOG_DIR/online.log"
  OFFLINE_LOG="$LOG_DIR/offline.log"

  info "Ensuring log directory: $LOG_DIR"
  try mkdir -p "$LOG_DIR"
  try touch "$ONLINE_LOG" "$OFFLINE_LOG"
  chmod 644 "$ONLINE_LOG" "$OFFLINE_LOG"

  perform_health_check "$BASE_URL"
}

main "$@"