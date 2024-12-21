#!/usr/bin/env bash
set -e

# ==============================
# Minimal Nginx Redirect Setup
# ==============================
# This script installs Nginx (if needed) and configures it to
# issue a 301 redirect to PROXY_TARGET.
#
# For example, hitting http://your_server/anything
# will redirect to https://my-target/anything
# ==============================

PROXY_TARGET="https://georgrybski.github.io/uninter/portfolio"

detect_package_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unsupported"
    fi
}

install_nginx() {
    local pkg_manager="$1"

    echo "Installing Nginx if not already present..."

    case "$pkg_manager" in
        apt)
            sudo apt-get update -y
            sudo apt-get install -y nginx
            ;;
        dnf)
            sudo dnf install -y nginx
            ;;
        yum)
            sudo yum install -y epel-release
            sudo yum install -y nginx
            ;;
        zypper)
            sudo zypper install -y nginx
            ;;
        *)
            echo "Error: Unsupported package manager."
            exit 1
            ;;
    esac

    sudo systemctl enable nginx
    sudo systemctl start nginx
}

configure_nginx() {
    local nginx_conf="/etc/nginx/conf.d/redirect.conf"

    echo "Configuring Nginx to redirect all traffic to:"
    echo "  $PROXY_TARGET"

    # Overwrite or create a simple config that issues a 301 redirect
    sudo tee "$nginx_conf" >/dev/null <<EOF
server {
    listen 80;
    listen [::]:80;

    return 301 ${PROXY_TARGET}\$request_uri;
}
EOF

    # Validate config and reload
    sudo nginx -t
    sudo systemctl reload nginx
    echo "Nginx configuration updated and reloaded."
}

main() {
    local pkg_manager
    pkg_manager="$(detect_package_manager)"

    if [[ "$pkg_manager" == "unsupported" ]]; then
        echo "Error: Unsupported package manager."
        exit 1
    fi

    install_nginx "$pkg_manager"
    configure_nginx
    echo "Setup complete!"
}

main "$@"