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

Schedules the Nginx health check script to run every 5 minutes via cron.

Options:
  --address <ADDRESS>   Base URL to check (default: http://127.0.0.1)
  -h, --help            Show this help message
EOF
    exit 1
}

info()    { echo -e "\033[0;32m[INFO]\033[0m $*"; }
error()   { echo -e "\033[0;31m[ERROR]\033[0m $*" >&2; }
die()     { error "$*"; exit 1; }

ensure_sudo() { sudo -n true 2>/dev/null || die "Script requires sudo privileges."; }

download_script() {
    if [[ ! -f "$LOCAL_SCRIPT_PATH" ]]; then
        info "Downloading monitoring script to $LOCAL_SCRIPT_PATH..."
        curl -fsSL "$REPO_URL" -o "$LOCAL_SCRIPT_PATH" || die "Failed to download the script from $REPO_URL."
    else
        info "Script already exists at $LOCAL_SCRIPT_PATH. Skipping download."
    fi

    chmod +x "$LOCAL_SCRIPT_PATH" || die "Failed to make the script executable."
}

validate_script_dependencies() {
    info "Validating dependencies for $LOCAL_SCRIPT_PATH..."
    for cmd in jq curl; do
        command -v "$cmd" &>/dev/null || die "Dependency '$cmd' is missing. Please install it."
    done
    info "All dependencies are available."
}

setup_cron_job() {
    local cron_job="$CRON_JOB_SCHEDULE $LOCAL_SCRIPT_PATH --address $ADDRESS >> $CRON_LOG_FILE 2>&1"

    info "Ensuring cron log directory: $CRON_LOG_DIR"
    mkdir -p "$CRON_LOG_DIR" || die "Failed to create log directory: $CRON_LOG_DIR"
    touch "$CRON_LOG_FILE" || die "Failed to create log file: $CRON_LOG_FILE"
    chmod 644 "$CRON_LOG_FILE" || die "Failed to set permissions on log file: $CRON_LOG_FILE"

    info "Setting up cron job..."
    (crontab -l 2>/dev/null | grep -v "$LOCAL_SCRIPT_PATH"; echo "$cron_job") | crontab - || die "Failed to add the cron job."

    info "Cron job successfully added:"
    crontab -l | grep "$LOCAL_SCRIPT_PATH"
}

verify_cron_job() {
    info "Verifying cron job..."
    if crontab -l | grep -q "$LOCAL_SCRIPT_PATH"; then
        info "Cron job is registered successfully."
    else
        die "Cron job registration failed."
    fi
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

    download_script
    validate_script_dependencies
    setup_cron_job
    verify_cron_job

    info "Nginx health endpoint monitoring setup completed."
}

main "$@"
