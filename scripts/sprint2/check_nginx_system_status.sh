#!/usr/bin/env bash
set -e

# ==============================
# Nginx System Status Checker
# ==============================
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
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Checks the Nginx service status and appends JSON log entries to:"
  echo "  /var/log/nginx_status/online.log   or"
  echo "  /var/log/nginx_status/offline.log"
  echo
  echo "Options:"
  echo "  -v, --verbose  Show verbose internal command logs"
  echo "  -h, --help     Show this help message"
  exit 1
}

parse_arguments() {
  VERBOSE=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--verbose)
        VERBOSE=true
        shift
        ;;
      -h|--help)
        usage
        ;;
      *)
        error "Unknown option: $1"
        usage
        ;;
    esac
  done
}

parse_arguments "$@"

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
      install_package_apt "$package"
      ;;
    dnf)
      install_package_dnf "$package"
      ;;
    unsupported)
      error "Unsupported package manager. Cannot install $package."
      exit 1
      ;;
  esac
}

install_package_apt() {
  local package="$1"
  if [[ "$VERBOSE" == true ]]; then
    sudo apt-get update -y
    sudo apt-get install -y "$package"
  else
    sudo apt-get update -y &>/dev/null
    sudo apt-get install -y "$package" &>/dev/null
  fi
}

install_package_dnf() {
  local package="$1"
  if [[ "$VERBOSE" == true ]]; then
    sudo dnf install -y "$package"
  else
    sudo dnf install -y "$package" &>/dev/null
  fi
}

ensure_jq() {
  if ! command -v jq &>/dev/null; then
    info "'jq' is not installed. Installing 'jq'..."
    install_package jq
    info "'jq' installation completed."
  else
    verbose "'jq' is already installed."
  fi
}

ensure_jq

get_instance_metadata() {
  if curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/ >/dev/null; then
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
  else
    INSTANCE_ID="${INSTANCE_ID:-localhost}"
    REGION="${REGION:-unknown}"
  fi
}

get_instance_metadata

LOG_DIR="/var/log/nginx_status"
ONLINE_LOG="$LOG_DIR/online.log"
OFFLINE_LOG="$LOG_DIR/offline.log"

info "Ensuring log directory: $LOG_DIR"
sudo mkdir -p "$LOG_DIR"
sudo touch "$ONLINE_LOG" "$OFFLINE_LOG"
sudo chmod 666 "$ONLINE_LOG" "$OFFLINE_LOG"

json_log() {
  local status="$1"
  local message="$2"
  local timestamp
  timestamp=$(date +"%Y-%m-%dT%H:%M:%SZ")

  local json_line
  json_line=$(
    jq -nc \
      --arg ts "$timestamp" \
      --arg svc "nginx" \
      --arg st "$status" \
      --arg msg "$message" \
      --arg iid "$INSTANCE_ID" \
      --arg rgn "$REGION" \
      '{
        "timestamp": $ts,
        "service": $svc,
        "status": $st,
        "message": $msg,
        "instance_id": $iid,
        "region": $rgn
      }'
  )

  local log_file
  if [[ "$status" == "online" ]]; then
    log_file="$ONLINE_LOG"
  else
    log_file="$OFFLINE_LOG"
  fi

  echo "$json_line" | sudo tee -a "$log_file" >/dev/null
}

verbose "Checking Nginx status..."

if command -v systemctl &>/dev/null; then
  verbose "Using 'systemctl' to check Nginx status."
  STATUS_OUTPUT=$(systemctl is-active nginx || true)
  if [[ "$STATUS_OUTPUT" == "active" ]]; then
    STATUS="online"
    MESSAGE="Nginx is running."
  else
    STATUS="offline"
    MESSAGE="Nginx is not running."
  fi
elif command -v service &>/dev/null; then
  verbose "Using 'service' command to check Nginx status."
  STATUS_OUTPUT=$(service nginx status || true)
  if echo "$STATUS_OUTPUT" | grep -qi "running"; then
    STATUS="online"
    MESSAGE="Nginx is running."
  else
    STATUS="offline"
    MESSAGE="Nginx is not running."
  fi
else
  error "Neither 'systemctl' nor 'service' command is available."
  STATUS="offline"
  MESSAGE="No valid command to check Nginx status."
fi

json_log "$STATUS" "$MESSAGE"
exit "$([[ "$STATUS" == "online" ]] && echo 0 || echo 1)"
