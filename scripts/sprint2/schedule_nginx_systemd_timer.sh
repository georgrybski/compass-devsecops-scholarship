#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="nginx_status_check"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
TIMER_FILE="/etc/systemd/system/${SERVICE_NAME}.timer"
SCRIPT_URL="https://raw.githubusercontent.com/georgrybski/compass-devsecops-scholarship/main/scripts/sprint2/check_nginx_system_status.sh"
SCRIPT_PATH="/usr/local/bin/check_nginx_system_status.sh"

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Automates scheduling of the Nginx system status check using systemd timer.

Options:
  -h, --help     Show this help message
EOF
  exit 1
}

info() { echo -e "\033[0;32m[INFO]\033[0m $*"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $*" >&2; }
die() { error "$1"; exit "${2:-1}"; }

ensure_sudo() { sudo -n true 2>/dev/null || die "This script requires privileges."; }

cleanup_previous_setup() {
  info "Cleaning up previous timer and service..."
  systemctl list-units --type=timer --all | grep -q "${SERVICE_NAME}.timer" &&
    systemctl stop "${SERVICE_NAME}.timer" &&
    systemctl disable "${SERVICE_NAME}.timer" ||
    info "Timer not found or already stopped."

  systemctl list-units --type=service --all | grep -q "${SERVICE_NAME}.service" &&
    systemctl stop "${SERVICE_NAME}.service" &&
    systemctl disable "${SERVICE_NAME}.service" ||
    info "Service not found or already stopped."

  rm -f "$TIMER_FILE" "$SERVICE_FILE" || true

  systemctl daemon-reload
}


download_script() {
  info "Downloading the Nginx status check script to $SCRIPT_PATH"
  curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"
  chmod +x "$SCRIPT_PATH"
  [[ -x "$SCRIPT_PATH" ]] || die "Failed to download or set up the script at $SCRIPT_PATH"
}

create_service_file() {
  info "Creating systemd service file: $SERVICE_FILE"
  tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Check Nginx System Status
After=network.target

[Service]
ExecStart=$SCRIPT_PATH
StandardOutput=journal
StandardError=journal
User=root
EOF
  chmod 644 "$SERVICE_FILE"
}

create_timer_file() {
  info "Creating systemd timer file: $TIMER_FILE"
  tee "$TIMER_FILE" > /dev/null <<EOF
[Unit]
Description=Timer to run ${SERVICE_NAME}.service every 5 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF
  chmod 644 "$TIMER_FILE"
}

reload_systemd() {
  info "Reloading systemd daemon"
  systemctl daemon-reload
}

enable_and_start_timer() {
  info "Enabling and starting the timer: $SERVICE_NAME.timer"
  systemctl enable --now "${SERVICE_NAME}.timer"
  sleep 2
  systemctl restart "${SERVICE_NAME}.service"
}

verify_timer() {
  info "Verifying the systemd timer setup"
  systemctl list-timers --all | grep -i "$SERVICE_NAME" || die "Timer setup verification failed."

  info "Timer verified successfully:"
  systemctl list-timers --all | grep -i "$SERVICE_NAME"
}

main() {
  ensure_sudo

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage ;;
      *) die "Unknown option: $1" ;;
    esac
  done

  cleanup_previous_setup
  download_script
  create_service_file
  create_timer_file
  reload_systemd
  enable_and_start_timer
  verify_timer

  info "Systemd timer for Nginx status check has been successfully set up!"
}

main "$@"
