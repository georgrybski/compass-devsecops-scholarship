#!/usr/bin/env bash
set -e

usage() {
    echo "Usage: $0 [path_to_frontend]"
    echo "If no path is provided, it defaults to a directory named 'frontend' in the current location."
    echo "Ensure the 'frontend' directory exists and contains your front-end files."
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Get the front-end directory from the first argument, default to 'frontend'
FRONTEND_DIR=${1:-frontend}

detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
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
    local pkg_manager=$1

    echo "Detected package manager: $pkg_manager"

    case $pkg_manager in
        apt)
            sudo apt-get update -y
            sudo apt-get install -y nginx
            ;;
        dnf)
            sudo dnf install -y epel-release
            sudo dnf install -y nginx
            ;;
        yum)
            sudo yum install -y epel-release
            sudo yum install -y nginx
            ;;
        zypper)
            sudo zypper refresh
            sudo zypper install -y nginx
            ;;
        *)
            echo "Unsupported package manager. Please install Nginx manually."
            exit 1
            ;;
    esac
}

deploy_frontend() {
    local frontend_source=$1
    local nginx_root="/var/www/html"

    # Check if front-end source exists
    if [[ ! -d "$frontend_source" ]]; then
        echo "Front-end directory '$frontend_source' does not exist."
        echo "Please provide a valid front-end directory or ensure the default 'frontend' directory exists."
        exit 1
    fi

    # Check if the front-end directory is not empty
    if [[ -z "$(ls -A "$frontend_source")" ]]; then
        echo "Front-end directory '$frontend_source' is empty."
        echo "Please provide a directory with your front-end files."
        exit 1
    fi

    echo "Deploying front-end from '$frontend_source' to '$nginx_root'..."

    # Remove existing content in nginx root
    sudo rm -rf "$nginx_root"/*

    # Copy front-end files to nginx root
    sudo cp -r "$frontend_source"/* "$nginx_root"

    # Set proper permissions
    sudo chown -R www-data:www-data "$nginx_root"
    sudo chmod -R 755 "$nginx_root"

    echo "Front-end deployed successfully."
}

configure_nginx() {
    local nginx_conf="/etc/nginx/sites-available/default"

    echo "Configuring Nginx to serve the front-end..."

    sudo bash -c 'cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Optional: Enable gzip compression for better performance
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF'

    echo "Testing Nginx configuration..."
    sudo nginx -t

    echo "Restarting Nginx to apply changes..."
    sudo systemctl restart nginx

    echo "Nginx configured successfully."
}

validate_setup() {
    echo "Validating Nginx setup by accessing http://localhost..."

    sleep 2

    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "Validation successful: Nginx is serving content correctly at http://localhost"
    else
        echo "Validation failed: Received HTTP status code $HTTP_STATUS"
        exit 1
    fi
}

# Main script execution

echo "Starting Nginx deployment script..."

PKG_MANAGER=$(detect_package_manager)

if [[ $PKG_MANAGER == "unsupported" ]]; then
    echo "Error: Unsupported package manager."
    exit 1
fi

install_nginx "$PKG_MANAGER"

deploy_frontend "$FRONTEND_DIR"

configure_nginx

validate_setup

echo "Nginx deployment completed successfully."