#!/usr/bin/env bash

set -e

INSTALL_DIR="/usr/local/share/brbr"
BIN_DIR="/usr/local/bin"

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

check_permissions() {
    if [ ! -w "$BIN_DIR" ]; then
        print_error "You need root permissions to uninstall BrBr"
        echo "Please run this script with sudo:"
        echo "  sudo $0"
        exit 1
    fi
}

# Ask for confirmation
read -p "Are you sure you want to uninstall BrBr? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 1
fi

check_permissions

print_step "Uninstalling BrBr..."

# Remove symlink
if [ -L "$BIN_DIR/brbr" ]; then
    rm "$BIN_DIR/brbr"
    print_success "Removed symlink: $BIN_DIR/brbr"
else
    print_error "Symlink not found: $BIN_DIR/brbr"
fi

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    print_success "Removed installation directory: $INSTALL_DIR"
else
    print_error "Installation directory not found: $INSTALL_DIR"
fi

print_success "BrBr uninstalled successfully!"
