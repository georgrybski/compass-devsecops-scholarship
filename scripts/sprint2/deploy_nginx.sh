#!/usr/bin/env bash
set -e

usage() {
    echo "Usage: $0 [path_to_frontend_or_url]"
    echo "If no argument is provided, it defaults to downloading a predefined front-end archive."
    echo "Provide either a local directory path containing your front-end files or a URL to download them."
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Get the front-end source from the first argument, default to a predefined URL
FRONTEND_SOURCE=${1:-"https://georgrybski.github.io/uninter/portfolio/index.html"}

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
        echo "Neither curl nor wget is installed. Installing wget..."
        install_downloader
    fi
}

install_downloader() {
    local pkg_manager=$(detect_package_manager)

    case $pkg_manager in
        apt)
            sudo apt-get update -y
            sudo apt-get install -y wget
            ;;
        dnf)
            sudo dnf install -y wget
            ;;
        yum)
            sudo yum install -y wget
            ;;
        zypper)
            sudo zypper refresh
            sudo zypper install -y wget
            ;;
        *)
            echo "Unsupported package manager. Please install curl or wget manually."
            exit 1
            ;;
    esac

    if command -v wget &> /dev/null; then
        DOWNLOADER="wget"
    elif command -v curl &> /dev/null; then
        DOWNLOADER="curl"
    else
        echo "Failed to install curl or wget. Please install manually."
        exit 1
    fi
}

is_url() {
    if [[ "$1" =~ ^https?:// ]]; then
        return 0
    else
        return 1
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

    if [[ "$archive_name" == *.zip ]]; then
        install_unzip
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

    TEMP_DIR_PATH="$temp_dir"
}

install_unzip() {
    if ! command -v unzip &> /dev/null; then
        echo "unzip not found. Installing unzip..."
        local pkg_manager=$(detect_package_manager)
        case $pkg_manager in
            apt)
                sudo apt-get install -y unzip
                ;;
            dnf)
                sudo dnf install -y unzip
                ;;
            yum)
                sudo yum install -y unzip
                ;;
            zypper)
                sudo zypper install -y unzip
                ;;
            *)
                echo "Unsupported package manager. Please install unzip manually."
                exit 1
                ;;
        esac
    fi
}

download_static_site() {
    local url=$1
    local temp_dir
    temp_dir=$(mktemp -d)
    echo "Downloading static site from $url recursively into $temp_dir..."

    if [[ "$DOWNLOADER" == "wget" ]]; then
        wget --recursive --no-clobber --page-requisites --html-extension --convert-links --no-parent "$url" -P "$temp_dir/extracted"
    elif [[ "$DOWNLOADER" == "curl" ]]; then
        echo "Recursive download with curl is not straightforward. Please use wget or provide an archive."
        exit 1
    fi

    FRONTEND_SOURCE_DIR="$temp_dir/extracted"

    echo "Static site downloaded to $FRONTEND_SOURCE_DIR"

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

if is_url "$FRONTEND_SOURCE"; then
    # Determine if the URL points to an archive based on its extension
    if [[ "$FRONTEND_SOURCE" =~ \.zip$ || "$FRONTEND_SOURCE" =~ \.tar\.gz$ || "$FRONTEND_SOURCE" =~ \.tgz$ ]]; then
        download_and_extract_frontend "$FRONTEND_SOURCE"
    else
        # Assume it's a static site and download recursively
        download_static_site "$FRONTEND_SOURCE"
    fi
else
    # Assume it's a local directory
    FRONTEND_SOURCE_DIR="$FRONTEND_SOURCE"

    # Check if the front-end directory exists
    if [[ ! -d "$FRONTEND_SOURCE_DIR" ]]; then
        echo "Front-end directory '$FRONTEND_SOURCE_DIR' does not exist."
        echo "Please provide a valid front-end directory or a valid URL."
        exit 1
    fi

    # Check if the front-end directory is not empty
    if [[ -z "$(ls -A "$FRONTEND_SOURCE_DIR")" ]]; then
        echo "Front-end directory '$FRONTEND_SOURCE_DIR' is empty."
        echo "Please provide a directory with your front-end files or a valid URL."
        exit 1
    fi
fi

deploy_frontend "$FRONTEND_SOURCE_DIR"

configure_nginx

# Validate the setup
validate_setup

echo "Nginx deployment completed successfully."
