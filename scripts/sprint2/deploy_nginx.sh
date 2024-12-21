#!/usr/bin/env bash
set -e

usage() {
    echo "Usage: $0 [url_to_frontend_archive]"
    echo "If no URL is provided, it defaults to downloading a predefined front-end archive."
    echo "Ensure the URL points to a valid front-end archive (e.g., .zip or .tar.gz)."
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

FRONTEND_URL=${1:-"https://example.com/path/to/default/frontend.zip"}

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

check_downloader() {
    if command -v curl &> /dev/null; then
        DOWNLOADER="curl"
    elif command -v wget &> /dev/null; then
        DOWNLOADER="wget"
    else
        echo "Neither curl nor wget is installed. Installing curl..."
        install_downloader
    fi
}

install_downloader() {
    local pkg_manager=$(detect_package_manager)

    case $pkg_manager in
        apt)
            sudo apt-get update -y
            sudo apt-get install -y curl
            ;;
        dnf)
            sudo dnf install -y curl
            ;;
        yum)
            sudo yum install -y curl
            ;;
        zypper)
            sudo zypper refresh
            sudo zypper install -y curl
            ;;
        *)
            echo "Unsupported package manager. Please install curl or wget manually."
            exit 1
            ;;
    esac

    if command -v curl &> /dev/null; then
        DOWNLOADER="curl"
    elif command -v wget &> /dev/null; then
        DOWNLOADER="wget"
    else
        echo "Failed to install curl or wget. Please install manually."
        exit 1
    fi
}

download_and_extract_frontend() {
    local url=$1
    local temp_dir
    temp_dir=$(mktemp -d)
    local archive_name="$temp_dir/frontend_archive"

    echo "Downloading front-end archive from $url..."

    if [[ "$DOWNLOADER" == "curl" ]]; then
        curl -L "$url" -o "$archive_name"
    else
        wget "$url" -O "$archive_name"
    fi

    echo "Download complete. Extracting archive..."

    # Determine archive type and extract accordingly
    if [[ "$archive_name" == *.zip ]]; then
        sudo apt-get install -y unzip || sudo yum install -y unzip || sudo dnf install -y unzip || sudo zypper install -y unzip
        unzip "$archive_name" -d "$temp_dir/extracted"
    elif [[ "$archive_name" == *.tar.gz || "$archive_name" == *.tgz ]]; then
        tar -xzf "$archive_name" -C "$temp_dir/extracted"
    else
        echo "Unsupported archive format. Please provide a .zip or .tar.gz archive."
        exit 1
    fi

    FRONTEND_SOURCE_DIR=$(find "$temp_dir/extracted" -mindepth 1 -maxdepth 1 -type d | head -n 1)

    if [[ -z "$FRONTEND_SOURCE_DIR" ]]; then
        echo "Failed to locate extracted front-end directory."
        exit 1
    fi

    echo "Front-end extracted to $FRONTEND_SOURCE_DIR"

    # Export the temp directory path for cleanup
    TEMP_DIR_PATH="$temp_dir"
}

deploy_frontend() {
    local frontend_source=$1
    local nginx_root="/var/www/html"

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

    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost || wget -q --spider http://localhost && echo "200" || echo "000")

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "Validation successful: Nginx is serving content correctly at http://localhost"
    else
        echo "Validation failed: Received HTTP status code $HTTP_STATUS"
        exit 1
    fi
}

cleanup() {
    if [[ -n "$TEMP_DIR_PATH" && -d "$TEMP_DIR_PATH" ]]; then
        sudo rm -rf "$TEMP_DIR_PATH"
        echo "Cleaned up temporary files."
    fi
}

# Trap to ensure cleanup is called on exit
trap cleanup EXIT

# Main script execution

echo "Starting Nginx deployment script..."

PKG_MANAGER=$(detect_package_manager)

if [[ $PKG_MANAGER == "unsupported" ]]; then
    echo "Error: Unsupported package manager."
    exit 1
fi

install_nginx "$PKG_MANAGER"

check_downloader

download_and_extract_frontend "$FRONTEND_URL"

deploy_frontend "$FRONTEND_SOURCE_DIR"

configure_nginx

validate_setup

echo "Nginx deployment completed successfully."