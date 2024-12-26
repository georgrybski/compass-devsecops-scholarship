#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/3-automate-nginx-status-check-scripts/scripts/sprint2/check_nginx_health_endpoint.sh"
LOCAL_SCRIPT_PATH="/usr/local/bin/check_nginx_health_endpoint.sh"
CRON_LOG_DIR="/var/log/nginx_health_cron"
CRON_LOG_FILE="$CRON_LOG_DIR/health_check.log"
CRON_JOB_SCHEDULE="*/5 * * * *"
ADDRESS="http://127.0.0.1"

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Schedules the Nginx health check script to run every 5 minutes.

Options:
  --address <ADDRESS>   Base URL to check (default: http://127.0.0.1)
  -h, --help            Show this help message
EOF
    exit 1
}

info() { echo -e "\033[0;32m[INFO]\033[0m $*"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $*" >&2; }
die() { error "$*"; exit 1; }
try() { "$@" || die "Command failed: $*"; }

ensure_sudo() { sudo -n true 2>/dev/null || die "Script requires sudo privileges."; }

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
        crontab) echo "cron" ;;
        *) return 1 ;;
      esac
      ;;
    dnf)
      case "$cmd" in
        jq) echo "jq" ;;
        curl) echo "curl" ;;
        crontab) echo "cronie" ;;
        *) return 1 ;;
      esac
      ;;
    *) return 1 ;;
  esac
  return 0
}

install_package() {
  local pkg="$1" pm="$2"

  info "Using $pm to install '$pkg'"
  case "$pm" in
    apt) {
      try sudo apt-get update -y
      try sudo apt-get install -y "$pkg"
    } ;;
    dnf) try sudo dnf install -y "$pkg" ;;
    *) die "Unsupported package manager: $pm" ;;
  esac
  return 0
}

ensure_command_available() {
  local cmd="$1"

  command -v "$cmd" &>/dev/null && return 0

  local pm
  pm=$(detect_package_manager) || die "No supported package manager found."

  local pkg
  pkg=$(map_package_name "$cmd" "$pm") || die "Could not map package for command: $cmd"

  info "'$cmd' is not installed. Installing '$pkg'..."
  install_package "$pkg" "$pm" || die "Failed to install package: $pkg"

  command -v "$cmd" &>/dev/null || die "'$cmd' is still not available after installation."
}

download_script() {
  if [[ ! -f "$LOCAL_SCRIPT_PATH" ]]; then
    info "Downloading monitoring script to $LOCAL_SCRIPT_PATH..."
    curl -fsSL "$REPO_URL" -o "$LOCAL_SCRIPT_PATH" || die "Failed to download the script from $REPO_URL."
  else
    info "Script already exists at $LOCAL_SCRIPT_PATH. Skipping download."
  fi

  info "Setting ownership and permissions for $LOCAL_SCRIPT_PATH"
  sudo chown root:root "$LOCAL_SCRIPT_PATH" || die "Failed to change ownership to root."
  sudo chmod 755 "$LOCAL_SCRIPT_PATH" || die "Failed to set permissions on the script."
}

setup_cron_job() {
  local cron_job="$CRON_JOB_SCHEDULE sudo $LOCAL_SCRIPT_PATH --address $ADDRESS >> $CRON_LOG_FILE 2>&1"

  info "Ensuring cron log directory: $CRON_LOG_DIR"
  sudo mkdir -p "$CRON_LOG_DIR" || die "Failed to create log directory: $CRON_LOG_DIR"
  sudo touch "$CRON_LOG_FILE" || die "Failed to create log file: $CRON_LOG_FILE"
  sudo chmod 644 "$CRON_LOG_FILE" || die "Failed to set permissions on log file: $CRON_LOG_FILE"

  info "Cleaning up any existing cron jobs for this script..."
  (crontab -l 2>/dev/null | grep -v "$LOCAL_SCRIPT_PATH") | sudo crontab - || die "Failed to clean up old cron jobs."

  info "Adding new cron job..."
  (crontab -l 2>/dev/null; echo "$cron_job") | sudo crontab - || die "Failed to add the cron job."

  info "Cron job successfully added:"
  sudo crontab -l | grep "$LOCAL_SCRIPT_PATH"
}


main() {
  ensure_sudo

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --address) {
        shift
        [[ $# -gt 0 ]] || die "Missing value for --address"
        ADDRESS="$1"
      } ;;
      -h|--help) usage ;;
      *) die "Unknown argument: $1" ;;
    esac
    shift
  done

  info "Using address: $ADDRESS"

  for cmd in jq curl crontab; do
    ensure_command_available "$cmd"
  done

  download_script
  setup_cron_job

  info "Nginx health endpoint monitoring setup completed."
}

main "$@"
