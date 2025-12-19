#!/bin/bash

# Dotfiles installation script
# Detects platform, installs packages and stow, and stows all packages

set -e  # Exit on any error

# Package mappings: dotfile_name -> binary_name
declare -A BINARY_MAP=(
    ["alacritty"]="alacritty"
    ["btop"]="btop"
    ["i3"]="i3"
    ["i3status"]="i3status"
    ["i3status-rust"]="i3status-rs"
    ["neofetch"]="neofetch"
    ["nvim"]="nvim"
    ["rofi"]="rofi"
    ["starship"]="starship"
    ["wal"]="wal"
)

# Package mappings: dotfile_name -> pacman_package_name
declare -A PACMAN_MAP=(
    ["alacritty"]="alacritty"
    ["btop"]="btop"
    ["i3"]="i3-wm"
    ["i3status"]="i3status"
    ["i3status-rust"]="i3status-rust"
    ["neofetch"]="neofetch"
    ["nvim"]="neovim"
    ["rofi"]="rofi"
    ["starship"]="starship"
    ["wal"]="python-pywal"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect the operating system
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/debian_version ]; then
        OS="debian"
    elif [ -f /etc/arch-release ]; then
        OS="arch"
    else
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    fi
    echo $OS
}

# Function to install stow based on the platform
install_stow() {
    local os=$(detect_os)
    
    print_status "Detected OS: $os"
    
    # Check if stow is already installed
    if command -v stow &> /dev/null; then
        print_status "GNU Stow is already installed"
        return 0
    fi
    
    print_status "Installing GNU Stow..."
    
    case $os in
        "ubuntu"|"debian")
            sudo apt update
            sudo apt install -y stow
            ;;
        "arch"|"manjaro")
            sudo pacman -S --noconfirm stow
            ;;
        "fedora")
            sudo dnf install -y stow
            ;;
        "centos"|"rhel")
            sudo yum install -y stow
            ;;
        *)
            print_error "Unsupported operating system: $os"
            print_error "Please install GNU Stow manually"
            exit 1
            ;;
    esac
    
    # Verify installation
    if command -v stow &> /dev/null; then
        print_status "GNU Stow installed successfully"
    else
        print_error "Failed to install GNU Stow"
        exit 1
    fi
}

# Function to draw progress bar
draw_progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%*s" $filled | tr ' ' '='
    printf "%*s" $empty | tr ' ' ' '
    printf "] %d%% (%d/%d)" $percentage $current $total
}

# Function to check if a binary exists
check_binary() {
    local package_name="$1"
    local binary_name="${BINARY_MAP[$package_name]:-$package_name}"

    if command -v "$binary_name" &> /dev/null; then
        echo "✓"
    else
        echo "✗"
    fi
}

# Function to get pacman package name
get_pacman_package() {
    local package_name="$1"
    echo "${PACMAN_MAP[$package_name]:-$package_name}"
}

# Function to install missing packages
install_packages() {
    local os=$(detect_os)
    local packages_to_install=()

    print_status "Checking for missing packages..."

    # Find all dotfile packages
    local dotfile_packages=$(find . -maxdepth 1 -type d -not -name '.*' -not -name '.' | sed 's|./||' | sort)

    for package in $dotfile_packages; do
        local binary_name="${BINARY_MAP[$package]:-$package}"
        if ! command -v "$binary_name" &> /dev/null; then
            packages_to_install+=("$package")
        fi
    done

    if [ ${#packages_to_install[@]} -eq 0 ]; then
        print_status "All packages are already installed"
        return 0
    fi

    print_warning "Missing packages: ${packages_to_install[*]}"

    case $os in
        "arch"|"manjaro")
            local pacman_packages=()
            for package in "${packages_to_install[@]}"; do
                local pacman_pkg=$(get_pacman_package "$package")
                pacman_packages+=("$pacman_pkg")
            done

            print_status "Installing packages via pacman: ${pacman_packages[*]}"
            sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"
            ;;
        "ubuntu"|"debian")
            print_warning "Automatic package installation for Debian/Ubuntu not fully implemented"
            print_warning "Please install manually: ${packages_to_install[*]}"
            ;;
        *)
            print_warning "Automatic package installation not supported for: $os"
            print_warning "Please install manually: ${packages_to_install[*]}"
            ;;
    esac
}

# Function to stow all packages with progress bar
stow_packages() {
    local dotfiles_dir="${1:-$HOME/.dotfiles}"
    local force_mode=$2
    
    if [ ! -d "$dotfiles_dir" ]; then
        print_error "Dotfiles directory not found: $dotfiles_dir"
        exit 1
    fi
    
    cd "$dotfiles_dir"
    
    print_status "Stowing packages from: $dotfiles_dir"
    
    # Find all directories (packages) in the dotfiles directory
    # Exclude .git and other hidden directories
    local packages=$(find . -maxdepth 1 -type d -not -name '.*' -not -name '.' | sed 's|./||' | sort)
    
    if [ -z "$packages" ]; then
        print_warning "No packages found to stow"
        return 0
    fi
    
    # Convert to array for easier handling
    local package_array=($packages)
    local total_packages=${#package_array[@]}
    
    # Show packages with binary detection
    local package_list=""
    for package in $packages; do
        local status=$(check_binary "$package")
        package_list="$package_list $package($status)"
    done
    
    print_status "Found ${total_packages} packages:$package_list"
    print_warning "Binary detection assumes package name = binary name and might not be accurate"
    echo ""
    local total_packages=${#package_array[@]}
    local current_package=0
    local stowed_count=0
    local error_count=0
    local unchanged_count=0
    
    # Stow each package with progress bar
    for package in "${package_array[@]}"; do
        current_package=$((current_package + 1))

        # Draw progress bar
        draw_progress_bar $current_package $total_packages

        # Capture stow output and check for success
        local stow_output
        local stow_success=false

        if [ "$force_mode" = true ]; then
            stow_output=$(stow --adopt "$package" 2>&1)
            stow_success=$?
        else
            stow_output=$(stow "$package" 2>&1)
            stow_success=$?
        fi

        if [ $stow_success -eq 0 ]; then
            # Check if anything was actually changed
            if echo "$stow_output" | grep -q "LINK"; then
                stowed_count=$((stowed_count + 1))
            else
                unchanged_count=$((unchanged_count + 1))
            fi
        else
            error_count=$((error_count + 1))
            # Clear the progress bar line and print error
            printf "\r%*s\r" 80 ""
            print_error "Failed to stow: $package"

            # Parse and display specific error
            if echo "$stow_output" | grep -q "existing target"; then
                print_warning "Conflict: Existing files found"
                echo "$stow_output" | grep "existing target" | sed 's/^/  /'
                if [ "$force_mode" != true ]; then
                    print_warning "Options:"
                    print_warning "  1. Use --force to adopt existing files into dotfiles"
                    print_warning "  2. Manually backup and remove conflicting files"
                    print_warning "  3. Skip this package"
                fi
            elif echo "$stow_output" | grep -q "cannot stow"; then
                print_warning "Stow error details:"
                echo "$stow_output" | sed 's/^/  /'
            else
                print_warning "Unknown error:"
                echo "$stow_output" | sed 's/^/  /'
            fi
            echo ""
        fi

        # Small delay to make progress visible
        sleep 0.1
    done
    
    # Clear progress bar and show final results
    printf "\r%*s\r" 80 ""
    echo -e "${GREEN}stowed: ${stowed_count}${NC}       ${RED}errors: ${error_count}${NC}       ${YELLOW}unchanged: ${unchanged_count}${NC}"
    echo ""
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -d, --directory DIR       Specify dotfiles directory (default: ~/.dotfiles)"
    echo "  -h, --help               Show this help message"
    echo "  --dry-run                Show what would be stowed without actually doing it"
    echo "  --force                  Use stow --adopt to adopt existing files"
    echo "  --skip-packages          Skip package installation"
    echo "  --skip-stow-install      Skip installing stow (assume it's already installed)"
}

# Main function
main() {
    local dotfiles_dir="$HOME/.dotfiles"
    local dry_run=false
    local force=false
    local skip_packages=false
    local skip_stow_install=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory)
                dotfiles_dir="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --force)
                force=true
                shift
                ;;
            --skip-packages)
                skip_packages=true
                shift
                ;;
            --skip-stow-install)
                skip_stow_install=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    print_status "Starting dotfiles installation..."

    # Install stow
    if [ "$skip_stow_install" = false ]; then
        install_stow
    else
        print_status "Skipping stow installation"
    fi
    
    # Change to dotfiles directory
    if [ ! -d "$dotfiles_dir" ]; then
        print_error "Dotfiles directory not found: $dotfiles_dir"
        print_error "Please clone your dotfiles repository first"
        exit 1
    fi
    
    cd "$dotfiles_dir"

    # Install packages unless skipped (pacman --needed will skip already installed)
    if [ "$skip_packages" = false ]; then
        install_packages
    else
        print_status "Skipping package installation"
    fi

    # Find packages
    local packages=$(find . -maxdepth 1 -type d -not -name '.*' -not -name '.' | sed 's|./||' | sort)

    if [ -z "$packages" ]; then
        print_warning "No packages found to stow in $dotfiles_dir"
        exit 0
    fi

    print_status "Found packages: $(echo $packages | tr '\n' ' ')"

    # Dry run mode
    if [ "$dry_run" = true ]; then
        print_status "DRY RUN - Would stow the following packages:"
        for package in $packages; do
            local status=$(check_binary "$package")
            echo "  - $package [$status]"
        done
        exit 0
    fi

    # Stow packages with progress bar
    stow_packages "$dotfiles_dir" "$force"

    print_status "Dotfiles installation complete!"
}

# Run main function with all arguments
main "$@"
