#!/usr/bin/env bash
set -e

# ==============================
# Nginx Front-End Deployment Script
# ==============================
# This script deploys a front-end application to Nginx.
# It supports deploying from:
#   1. A local directory containing front-end files.
#   2. A URL pointing to an archive (.zip, .tar.gz, .tgz).
#   3. A URL to a static website.
#   4. A Git repository URL.
#
# Usage:
#   ./deploy_nginx.sh [path_to_frontend_or_url]
#
# If no argument is provided, it defaults to a predefined URL.
# ==============================

# ------------------------------
# Configuration Variables
# ------------------------------
DEFAULT_FRONTEND_URL="https://georgrybski.github.io/uninter/portfolio/"  # Update this to your default source
NGINX_ROOT="/var/www/html"

# ------------------------------
# Usage Instructions
# ------------------------------
usage() {
    echo "========================================="
    echo "Nginx Front-End Deployment Script Usage"
    echo "========================================="
    echo ""
    echo "Usage: $0 [path_to_frontend_or_url]"
    echo ""
    echo "Arguments:"
    echo "  path_to_frontend_or_url   Path to a local directory containing front-end files OR"
    echo "                            URL to an archive (.zip, .tar.gz, .tgz) OR"
    echo "                            URL to a static website OR"
    echo "                            Git repository URL (.git)"
    echo ""
    echo "If no argument is provided, it defaults to downloading from:"
    echo "  $DEFAULT_FRONTEND_URL"
    echo ""
    echo "Examples:"
    echo "  Deploy from a local directory:"
    echo "    $0 /path/to/local/frontend"
    echo ""
    echo "  Deploy from a ZIP archive URL:"
    echo "    $0 https://example.com/frontend.zip"
    echo ""
    echo "  Deploy from a static site URL:"
    echo "    $0 https://example.com/static-site/"
    echo ""
    echo "  Deploy from a Git repository:"
    echo "    $0 https://github.com/user/repo.git"
    echo ""
    exit 1
}

# ------------------------------
# Cleanup Function
# ------------------------------
cleanup() {
    if [[ -n "$TEMP_DIR_PATH" && -d "$TEMP_DIR_PATH" ]]; then
        sudo rm -rf "$TEMP_DIR_PATH"
        echo "Cleaned up temporary files."
    fi
}

# Ensure cleanup is called on script exit
trap cleanup EXIT

# ------------------------------
# Detect Package Manager
# ------------------------------
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

# ------------------------------
# Install Nginx
# ------------------------------
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

# ------------------------------
# Check and Install Downloader (wget or curl)
# ------------------------------
check_downloader() {
    if command -v wget &> /dev/null; then
        DOWNLOADER="wget"
    elif command -v curl &> /dev/null; then
        DOWNLOADER="curl"
    else
        echo "Neither wget nor curl is installed. Installing wget..."
        install_downloader
    fi
}

# ------------------------------
# Install Downloader (prefers wget)
# ------------------------------
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
            echo "Unsupported package manager. Please install wget or curl manually."
            exit 1
            ;;
    esac

    if command -v wget &> /dev/null; then
        DOWNLOADER="wget"
    elif command -v curl &> /dev/null; then
        DOWNLOADER="curl"
    else
        echo "Failed to install wget or curl. Please install manually."
        exit 1
    fi
}

# ------------------------------
# Check and Install Git
# ------------------------------
check_git() {
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Installing Git..."
        local pkg_manager=$(detect_package_manager)
        case $pkg_manager in
            apt)
                sudo apt-get update -y
                sudo apt-get install -y git
                ;;
            dnf)
                sudo dnf install -y git
                ;;
            yum)
                sudo yum install -y git
                ;;
            zypper)
                sudo zypper refresh
                sudo zypper install -y git
                ;;
            *)
                echo "Unsupported package manager. Please install Git manually."
                exit 1
                ;;
        esac

        if ! command -v git &> /dev/null; then
            echo "Failed to install Git. Please install manually."
            exit 1
        fi
    fi
}

# ------------------------------
# Check and Install Unzip
# ------------------------------
install_unzip() {
    if ! command -v unzip &> /dev/null; then
        echo "unzip is not installed. Installing unzip..."
        local pkg_manager=$(detect_package_manager)
        case $pkg_manager in
            apt)
                sudo apt-get update -y
                sudo apt-get install -y unzip
                ;;
            dnf)
                sudo dnf install -y unzip
                ;;
            yum)
                sudo yum install -y unzip
                ;;
            zypper)
                sudo zypper refresh
                sudo zypper install -y unzip
                ;;
            *)
                echo "Unsupported package manager. Please install unzip manually."
                exit 1
                ;;
        esac

        if ! command -v unzip &> /dev/null; then
            echo "Failed to install unzip. Please install manually."
            exit 1
        fi
    fi
}

# ------------------------------
# Determine if Input is a URL
# ------------------------------
is_url() {
    # Simple regex to check if the input starts with http:// or https://
    if [[ "$1" =~ ^https?:// ]]; then
        return 0
    else
        return 1
    fi
}

# ------------------------------
# Determine if Input is a Git Repository
# ------------------------------
is_git_repo() {
    if [[ "$1" =~ \.git$ ]]; then
        return 0
    else
        return 1
    fi
}

# ------------------------------
# Download and Extract Archive
# ------------------------------
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
        install_unzip
        unzip "$archive_name" -d "$temp_dir/extracted"
    elif [[ "$archive_name" == *.tar.gz || "$archive_name" == *.tgz ]]; then
        tar -xzf "$archive_name" -C "$temp_dir/extracted"
    else
        echo "Unsupported archive format. Please provide a .zip or .tar.gz archive."
        exit 1
    fi

    # Assuming the archive contains a single directory; adjust as needed
    FRONTEND_SOURCE_DIR=$(find "$temp_dir/extracted" -mindepth 1 -maxdepth 1 -type d | head -n 1)

    if [[ -z "$FRONTEND_SOURCE_DIR" ]]; then
        echo "Failed to locate extracted front-end directory."
        exit 1
    fi

    echo "Front-end extracted to $FRONTEND_SOURCE_DIR"

    # Export the temp directory path for cleanup
    TEMP_DIR_PATH="$temp_dir"
}

# ------------------------------
# Download Static Site Recursively
# ------------------------------
download_static_site() {
    local url=$1
    local temp_dir
    temp_dir=$(mktemp -d)
    local extracted_dir="$temp_dir/extracted"

    # Create the extracted directory
    mkdir -p "$extracted_dir"

    echo "Downloading static site from $url recursively into $extracted_dir..."

    if [[ "$DOWNLOADER" == "wget" ]]; then
        # Enhanced wget command with additional flags
        wget --recursive \
             --no-clobber \
             --page-requisites \
             --html-extension \
             --convert-links \
             --no-parent \
             --domains "$(echo "$url" | awk -F/ '{print $3}')" \
             --restrict-file-names=windows \
             --level=5 \
             --directory-prefix="$extracted_dir" \
             --verbose \
             "$url"
    elif [[ "$DOWNLOADER" == "curl" ]]; then
        echo "Recursive download with curl is not straightforward. Please use wget or provide an archive."
        exit 1
    fi

    # Verify that files were downloaded
    if [[ ! -d "$extracted_dir" || -z "$(ls -A "$extracted_dir")" ]]; then
        echo "Failed to download the static site. Please check the URL and try again."
        exit 1
    fi

    FRONTEND_SOURCE_DIR="$extracted_dir"

    echo "Static site downloaded to $FRONTEND_SOURCE_DIR"

    # Export the temp directory path for cleanup
    TEMP_DIR_PATH="$temp_dir"
}

# ------------------------------
# Clone Git Repository
# ------------------------------
clone_repository() {
    local repo_url=$1
    local temp_dir
    temp_dir=$(mktemp -d)
    local extracted_dir="$temp_dir/extracted"

    echo "Cloning Git repository from $repo_url into $extracted_dir..."

    git clone "$repo_url" "$extracted_dir"

    if [[ $? -ne 0 ]]; then
        echo "Failed to clone the repository. Please check the repository URL."
        exit 1
    fi

    FRONTEND_SOURCE_DIR="$extracted_dir"
    TEMP_DIR_PATH="$temp_dir"

    echo "Repository cloned to $FRONTEND_SOURCE_DIR"
}

# ------------------------------
# Deploy Front-End to Nginx
# ------------------------------
deploy_frontend() {
    local frontend_source=$1
    local nginx_root=$2

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

# ------------------------------
# Configure Nginx to Serve Front-End
# ------------------------------
configure_nginx() {
    local nginx_conf="/etc/nginx/sites-available/default"

    echo "Configuring Nginx to serve the front-end..."

    sudo bash -c "cat > $nginx_conf <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root $NGINX_ROOT;
    index index.html index.htm;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Optional: Enable gzip compression for better performance
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF"

    echo "Testing Nginx configuration..."
    sudo nginx -t

    echo "Restarting Nginx to apply changes..."
    sudo systemctl restart nginx

    echo "Nginx configured successfully."
}

# ------------------------------
# Validate Nginx Deployment
# ------------------------------
validate_setup() {
    echo "Validating Nginx setup by accessing http://localhost..."

    sleep 2

    # Determine the validation tool
    if command -v curl &> /dev/null; then
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
    elif command -v wget &> /dev/null; then
        HTTP_STATUS=$(wget --spider -S http://localhost 2>&1 | grep "HTTP/" | awk '{print $2}' | head -n1)
    else
        echo "Neither curl nor wget is available for validation."
        exit 1
    fi

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "Validation successful: Nginx is serving content correctly at http://localhost"
    else
        echo "Validation failed: Received HTTP status code $HTTP_STATUS"
        exit 1
    fi
}

# ------------------------------
# Main Script Execution
# ------------------------------
main() {
    # Display usage if help flag is used
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        usage
    fi

    # Get the front-end source from the first argument, default to DEFAULT_FRONTEND_URL
    FRONTEND_SOURCE=${1:-"$DEFAULT_FRONTEND_URL"}

    echo "========================================="
    echo "Starting Nginx Front-End Deployment Script"
    echo "========================================="
    echo ""

    # Detect Package Manager
    PKG_MANAGER=$(detect_package_manager)

    if [[ "$PKG_MANAGER" == "unsupported" ]]; then
        echo "Error: Unsupported package manager."
        exit 1
    fi

    # Install Nginx
    install_nginx "$PKG_MANAGER"

    # Check for downloader and install if necessary
    check_downloader

    # Determine if the FRONTEND_SOURCE is a URL or a local directory
    if is_url "$FRONTEND_SOURCE"; then
        if is_git_repo "$FRONTEND_SOURCE"; then
            # It's a Git repository
            check_git
            clone_repository "$FRONTEND_SOURCE"
        elif [[ "$FRONTEND_SOURCE" =~ \.zip$ || "$FRONTEND_SOURCE" =~ \.tar\.gz$ || "$FRONTEND_SOURCE" =~ \.tgz$ ]]; then
            # It's an archive
            download_and_extract_frontend "$FRONTEND_SOURCE"
        else
            # Assume it's a static site and download recursively
            # Ensure the URL ends with a slash for wget to handle properly
            if [[ "$FRONTEND_SOURCE" != */ ]]; then
                FRONTEND_SOURCE="$FRONTEND_SOURCE/"
            fi
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

    # Deploy the front-end to Nginx
    deploy_frontend "$FRONTEND_SOURCE_DIR" "$NGINX_ROOT"

    # Configure Nginx to serve the front-end
    configure_nginx

    # Validate the setup
    validate_setup

    echo ""
    echo "========================================="
    echo "Nginx Front-End Deployment Completed Successfully!"
    echo "========================================="
}

# Execute the main function with all script arguments
main "$@"
