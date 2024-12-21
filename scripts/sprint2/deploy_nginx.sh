#!/usr/bin/env bash
set -e

# ==============================
# Minimal Nginx Setup for Fedora
# ==============================
# This script installs Nginx (if not already installed) and configures it
# pointing to a specified backend URL.
#
# Usage:
#   ./deploy_nginx.sh
#
# The script does NOT deploy any local files;
# All requests are proxied to PROXY_TARGET.
# ==============================

PROXY_TARGET="https://georgrybski.github.io/uninter/portfolio"

usage() {
    echo "Usage: $0"
    echo "Description: Installs and configures Nginx pointing to $PROXY_TARGET."
    exit 1
}

detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v apt-get &> /dev/null; then
        echo "apt-get"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "unsupported"
    fi
}

install_nginx() {
    local pkg_manager="$1"

    echo "Detected package manager: $pkg_manager"
    echo "Installing Nginx if not already installed..."

    case "$pkg_manager" in
        apt|apt-get)
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
            echo "Unsupported package manager. Please install Nginx manually."
            exit 1
            ;;
    esac

    sudo systemctl enable nginx
    sudo systemctl start nginx
}

configure_nginx() {
    local nginx_conf="/etc/nginx/conf.d/reverse-proxy.conf"

    # Ensure PROXY_TARGET is set
    if [[ -z "$PROXY_TARGET" ]]; then
        echo "Error: PROXY_TARGET is not set."
        exit 1
    fi

    echo "Configuring Nginx pointing to $PROXY_TARGET..."

    # Backup existing configuration if it exists
    if [[ -f "$nginx_conf" ]]; then
        sudo cp "$nginx_conf" "${nginx_conf}.bak.$(date +%s)"
        echo "Existing Nginx configuration backed up."
    fi

    # Write the new Nginx configuration using sudo tee with a quoted heredoc
    sudo tee "$nginx_conf" > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;
    return 301 PROXY_TARGET_PLACEHOLDER$request_uri;
}
EOF

    # Replace the placeholder with the actual PROXY_TARGET
    sudo sed -i "s|PROXY_TARGET_PLACEHOLDER|$PROXY_TARGET|" "$nginx_conf"

    if [[ ! -f "$nginx_conf" ]]; then
        echo "Error: Failed to create Nginx configuration file at $nginx_conf."
        exit 1
    fi

    echo "Testing Nginx configuration..."
    sudo nginx -t

    if [[ $? -ne 0 ]]; then
        echo "Error: Nginx configuration test failed. Please check the configuration."
        exit 1
    fi

    echo "Reloading Nginx..."
    sudo systemctl reload nginx

    echo "Nginx configured successfully."
}



validate_setup() {
    echo "Validating Nginx setup at http://localhost ..."
    sleep 2

    local http_status

    if command -v curl &> /dev/null; then
        http_status=$(curl -s -o /dev/null -w "%{http_code}" -L http://localhost)
    elif command -v wget &> /dev/null; then
        http_status=$(wget --spider -S http://localhost 2>&1 | grep 'HTTP/' | awk '{print $2}' | head -n1)
    else
        echo "Neither curl nor wget is installed. Cannot validate automatically."
        return
    fi

    if [[ "$http_status" == "200" ]]; then
        echo "Success! Received HTTP 200 from $PROXY_TARGET via http://localhost"
    elif [[ "$http_status" =~ ^30[12]$ ]]; then
        echo "Received redirect (HTTP $http_status). If your proxy target redirects HTTP to HTTPS, this is normal."
    else
        echo "Validation failed: Received HTTP status code $http_status"
    fi
}

main() {
    # If help requested
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        usage
    fi

    echo "========================================="
    echo " Nginx Pointing To: $PROXY_TARGET"
    echo "========================================="
    echo ""

    local pkg_manager
    pkg_manager="$(detect_package_manager)"

    if [[ "$pkg_manager" == "unsupported" ]]; then
        echo "Error: Unsupported package manager."
        exit 1
    fi

    install_nginx "$pkg_manager"
    configure_nginx
    validate_setup

    echo ""
    echo "========================================="
    echo " Nginx Setup Complete!"
    echo "========================================="
}

main "$@"
