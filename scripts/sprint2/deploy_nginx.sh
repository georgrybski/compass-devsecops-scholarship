#!/usr/bin/env bash
set -e

# ==============================
# Nginx Redirect Setup
# ==============================
# Installs Nginx and configures a redirect for "/portfolio" to PROXY_TARGET.
# Supports apt and dnf package managers.

PROXY_TARGET="https://georgrybski.github.io/uninter/portfolio"

usage() {
    echo "Usage: $0"
    echo
    echo "Sets up Nginx to redirect '/portfolio' to:"
    echo "  $PROXY_TARGET"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message"
    exit 1
}

detect_package_manager() {
    for pm in apt dnf; do
        command -v "$pm" &>/dev/null && echo "$pm" && return
    done
    echo "unsupported"
}

install_nginx() {
    local pkg_manager="$1"
    echo "Using package manager: $pkg_manager"

    case "$pkg_manager" in
        apt)
            sudo apt-get update -y
            sudo apt-get install -y nginx
            ;;
        dnf)
            sudo dnf install -y nginx
            ;;
    esac

    sudo systemctl enable nginx
    sudo systemctl start nginx
}

configure_nginx() {
    local nginx_conf="/etc/nginx/conf.d/redirect.conf"

    sudo tee "$nginx_conf" >/dev/null <<EOF
server {
    location /portfolio {
        return 301 ${PROXY_TARGET};
    }
}
EOF

    sudo nginx -t
    sudo systemctl reload nginx
    echo "Nginx configuration validated, updated and reloaded."
}

main() {
    [[ "$1" =~ ^-h|--help$ ]] && usage

    local pkg_manager
    pkg_manager=$(detect_package_manager)

    if [[ "$pkg_manager" == "unsupported" ]]; then
        echo "Error: Unsupported package manager."
        exit 1
    fi

    install_nginx "$pkg_manager"
    configure_nginx

    echo "Nginx redirect setup complete."
}

main "$@"