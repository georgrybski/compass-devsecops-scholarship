#!/usr/bin/env bash
set -e

# ==============================
# Nginx Redirect Setup
# ==============================
# Installs Nginx and configures a redirect for "/portfolio" to REDIRECT_TARGET.
# Supports apt and dnf package managers.

REDIRECT_TARGET="https://georgrybski.github.io/uninter/portfolio"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${GREEN}[INFO]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
verbose() { [[ "$VERBOSE" == true ]] && echo -e "$*"; }

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Sets up Nginx to redirect '/portfolio' to:"
  echo "  $REDIRECT_TARGET"
  echo
  echo "Options:"
  echo "  -h, --help     Show this help message"
  echo "  -v, --verbose  Show verbose internal command logs"
  exit 1
}

check_sudo() {
  if sudo -n true 2>/dev/null; then
    :
  else
    info "Sudo privileges are required to run this script."
    sudo -v || { error "Failed to obtain sudo privileges."; exit 1; }
  fi
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

detect_package_manager() {
  for pm in apt dnf; do
    if command -v "$pm" &>/dev/null; then
      echo "$pm"
      return
    fi
  done
  echo "unsupported"
}

install_nginx_apt() {
  if [[ "$VERBOSE" == true ]]; then
    sudo apt-get update -y
    sudo apt-get install -y nginx
  else
    sudo apt-get update -y &>/dev/null
    sudo apt-get install -y nginx &>/dev/null
  fi
}

install_nginx_dnf() {
  if [[ "$VERBOSE" == true ]]; then
    sudo dnf install -y nginx
  else
    sudo dnf install -y nginx &>/dev/null
  fi
}

enable_and_start_nginx() {
  if [[ "$VERBOSE" == true ]]; then
    sudo systemctl enable nginx
    sudo systemctl start nginx
  else
    sudo systemctl enable nginx &>/dev/null
    sudo systemctl start nginx &>/dev/null
  fi
}

install_nginx() {
  local pkg_manager="$1"

  info "Using package manager: $pkg_manager"

  case "$pkg_manager" in
    apt)
      install_nginx_apt
      ;;
    dnf)
      install_nginx_dnf
      ;;
    *)
      error "Unsupported package manager."
      exit 1
      ;;
  esac

  enable_and_start_nginx
  info "Nginx installed, enabled, and started."
}

remove_default_site() {
  # Removes default site to avoid conflicts in ubuntu
  if [[ "$VERBOSE" == true ]]; then
    sudo rm /etc/nginx/sites-enabled/default || true
  else
    sudo rm /etc/nginx/sites-enabled/default &>/dev/null || true
  fi
}

test_and_reload_nginx() {
  if [[ "$VERBOSE" == true ]]; then
    sudo nginx -t
    sudo systemctl reload nginx
  else
    sudo nginx -t &>/dev/null
    sudo systemctl reload nginx &>/dev/null
  fi
}

configure_nginx() {
  local nginx_conf="/etc/nginx/conf.d/redirect.conf"
  sudo tee "$nginx_conf" >/dev/null <<EOF
server {
    location /portfolio {
        return 301 ${REDIRECT_TARGET};
    }

    location /health {
        access_log off;
        return 200 "OK";
    }
}
EOF

  remove_default_site
  test_and_reload_nginx

  info "Nginx configuration validated, updated, and reloaded."
}

main() {
  parse_arguments "$@"

  check_sudo

  local pkg_manager
  pkg_manager=$(detect_package_manager)

  if [[ "$pkg_manager" == "unsupported" ]]; then
    error "Unsupported package manager."
    exit 1
  fi

  install_nginx "$pkg_manager"
  configure_nginx

  info "Nginx redirect setup complete."
}

main "$@"