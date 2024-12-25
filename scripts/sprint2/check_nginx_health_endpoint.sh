#!/usr/bin/env bash
set -e

# ===================================
# Nginx Health Endpoint Checker
# ===================================
# Checks if a given URL's /health endpoint returns HTTP 200.
# Logs JSON results to:
#   /var/log/nginx_health_endpoint/online.log   (if 200)
#   /var/log/nginx_health_endpoint/offline.log  (otherwise)

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

info()    { echo -e "${GREEN}[INFO]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
verbose() { [[ "$VERBOSE" == true ]] && echo -e "[VERBOSE] $*"; }

usage() {
  cat <<EOF
Usage: $0 [OPTIONS] <BASE_URL>

Checks the /health endpoint of <BASE_URL> and appends JSON results to:
  /var/log/nginx_health_endpoint/online.log   or
  /var/log/nginx_health_endpoint/offline.log

Example:
  $0 http://localhost

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
      -*)
        error "Unknown option: $1"
        usage
        ;;
      *)
        if [[ -z "$BASE_URL" ]]; then
          BASE_URL="$1"
        else
          error "Multiple BASE_URLs provided."
          usage
        fi
        ;;
    esac
    shift
  done

  if [[ -z "$BASE_URL" ]]; then
    error "BASE_URL is required."
    usage
  fi
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

  if [[ -z "$HTTP_CODE" ]]; then
    http_code_json="null"
  else
    http_code_json="$HTTP_CODE"
  fi

  jq -nc \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg svc "nginx_health_endpoint" \
    --arg st "$status" \
    --arg msg "$message" \
    --arg iid "$INSTANCE_ID" \
    --arg rgn "$REGION" \
    --argjson hc "$http_code_json" \
    '{
      timestamp: $ts,
      service: $svc,
      status: $st,
      message: $msg,
      http_code: $hc,
      instance_id: $iid,
      region: $rgn
    }' | sudo tee -a "$log_file" >/dev/null
}

perform_health_check() {
  local address="$1/health"
  verbose "Checking $address ..."

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$address" || true)

  if [[ "$HTTP_CODE" == "200" ]]; then
    log_json "online" "Nginx health endpoint returned code $HTTP_CODE."
    exit 0
  fi

  if [[ -z "$HTTP_CODE" ]]; then
    log_json "offline" "Nginx health endpoint did not return a valid HTTP code."
  else
    log_json "offline" "Nginx health endpoint returned code $HTTP_CODE."
  fi
  exit 1
}

main() {
  parse_arguments "$@"

  ensure_command_available "jq" "jq"
  ensure_command_available "ec2-metadata" "ec2-metadata"

  get_aws_instance_metadata

  LOG_DIR="/var/log/nginx_health_endpoint"
  ONLINE_LOG="$LOG_DIR/online.log"
  OFFLINE_LOG="$LOG_DIR/offline.log"

  info "Ensuring log directory: $LOG_DIR"
  sudo mkdir -p "$LOG_DIR"
  sudo touch "$ONLINE_LOG" "$OFFLINE_LOG"
  sudo chmod 666 "$ONLINE_LOG" "$OFFLINE_LOG"

  perform_health_check "$BASE_URL"
}

main "$@"