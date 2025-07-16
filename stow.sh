#!/bin/bash

# Dotfiles installation script
# Detects platform, installs stow, and stows all packages

set -e  # Exit on any error

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

# Function to stow all packages
stow_packages() {
    local dotfiles_dir="${1:-$HOME/.dotfiles}"
    
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
    
    print_status "Found packages: $(echo $packages | tr '\n' ' ')"
    
    # Stow each package
    for package in $packages; do
        print_status "Stowing package: $package"
        
        if stow "$package"; then
            print_status "Successfully stowed: $package"
        else
            print_error "Failed to stow: $package"
            print_warning "This might be due to existing files. Consider using 'stow --adopt $package' or removing conflicting files."
        fi
    done
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -d, --directory DIR    Specify dotfiles directory (default: ~/.dotfiles)"
    echo "  -h, --help            Show this help message"
    echo "  --dry-run             Show what would be stowed without actually doing it"
    echo "  --force               Use stow --adopt to adopt existing files"
}

# Main function
main() {
    local dotfiles_dir="$HOME/.dotfiles"
    local dry_run=false
    local force=false
    
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
    install_stow
    
    # Change to dotfiles directory
    if [ ! -d "$dotfiles_dir" ]; then
        print_error "Dotfiles directory not found: $dotfiles_dir"
        print_error "Please clone your dotfiles repository first"
        exit 1
    fi
    
    cd "$dotfiles_dir"
    
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
            echo "  - $package"
        done
        exit 0
    fi
    
    # Stow packages
    for package in $packages; do
        print_status "Stowing package: $package"
        
        if [ "$force" = true ]; then
            if stow --adopt "$package"; then
                print_status "Successfully adopted and stowed: $package"
            else
                print_error "Failed to stow: $package"
            fi
        else
            if stow "$package"; then
                print_status "Successfully stowed: $package"
            else
                print_error "Failed to stow: $package"
                print_warning "Try using --force to adopt existing files, or remove conflicting files manually"
            fi
        fi
    done
    
    print_status "Dotfiles installation complete!"
}

# Run main function with all arguments
main "$@"
