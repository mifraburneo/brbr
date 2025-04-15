#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_DIR="/usr/local/share/brbr"
BIN_DIR="/usr/local/bin"

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
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

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

check_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_deps=0
    
    for cmd in curl git openssl tar file fzf; do
        if ! command -v $cmd &>/dev/null; then
            print_error "$cmd is not installed"
            missing_deps=1
        else
            print_success "$cmd is installed"
        fi
    done
    
    if [ $missing_deps -eq 1 ]; then
        echo ""
        print_error "Some dependencies are missing. Please install them and try again."
        echo ""
        echo "On Ubuntu/Debian: sudo apt install curl git openssl tar file fzf"
        echo "On CentOS/RHEL: sudo yum install curl git openssl tar file"
        echo "  For fzf: git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install"
        exit 1
    fi
}

check_permissions() {
    if [ ! -w "$BIN_DIR" ]; then
        print_error "You need root permissions to install to $BIN_DIR"
        echo "Please run this script with sudo:"
        echo "  sudo $0"
        exit 1
    fi
}

download_binary() {
    print_step "Downloading navi binary..."
    
    # Create bin directory if it doesn't exist
    mkdir -p "$INSTALL_DIR/bin"
    
    # Use a specific version rather than latest to ensure stability
    local NAVI_VERSION="2.22.1"
    
    # First try to download the tar.gz and extract it
    curl -L -o "$INSTALL_DIR/bin/navi.tar.gz" \
        "https://github.com/denisidoro/navi/releases/download/v$NAVI_VERSION/navi-v$NAVI_VERSION-x86_64-unknown-linux-musl.tar.gz"
    
    if [ $? -eq 0 ]; then
        tar -xzf "$INSTALL_DIR/bin/navi.tar.gz" -C "$INSTALL_DIR/bin/"
        if [ -f "$INSTALL_DIR/bin/navi" ]; then
            chmod +x "$INSTALL_DIR/bin/navi"
            rm "$INSTALL_DIR/bin/navi.tar.gz"
            print_success "Navi binary downloaded and installed successfully"
        else
            print_error "Failed to extract navi binary from archive"
            return 1
        fi
    else
        print_warning "Failed to download tar.gz, trying direct binary download..."
        curl -L -o "$INSTALL_DIR/bin/navi" \
            "https://github.com/denisidoro/navi/releases/download/v$NAVI_VERSION/navi-linux-x86_64" \
            && chmod +x "$INSTALL_DIR/bin/navi"
        
        if [ $? -eq 0 ]; then
            print_success "Navi binary downloaded successfully"
        else
            print_error "Failed to download navi binary"
            return 1
        fi
    fi
    
    # Verify binary is executable
    if file "$INSTALL_DIR/bin/navi" | grep -q "executable"; then
        print_success "Binary verified as executable"
        return 0
    else
        print_error "Downloaded file is not an executable! Content:"
        head -n 3 "$INSTALL_DIR/bin/navi"
        return 1
    fi
}

install_brbr() {
    print_step "Installing BrBr..."
    
    # Create installation directories
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/bin"
    mkdir -p "$INSTALL_DIR/cheats"
    mkdir -p "$INSTALL_DIR/config"
    mkdir -p "$INSTALL_DIR/encrypted-cheats"
    mkdir -p "$INSTALL_DIR/private"
    
    # Copy the brbr wrapper script
    cp "$SCRIPT_DIR/bin/brbr" "$INSTALL_DIR/bin/"
    chmod +x "$INSTALL_DIR/bin/brbr"
    
    # Download navi binary
    download_binary || exit 1
    
    # Copy cheats and config
    cp -r "$SCRIPT_DIR/cheats"/* "$INSTALL_DIR/cheats/" 2>/dev/null || true
    cp -r "$SCRIPT_DIR/config"/* "$INSTALL_DIR/config/" 2>/dev/null || true
    [ -d "$SCRIPT_DIR/encrypted-cheats" ] && cp -r "$SCRIPT_DIR/encrypted-cheats"/* "$INSTALL_DIR/encrypted-cheats/" 2>/dev/null || true
    
    # Create symlink to brbr in BIN_DIR
    ln -sf "$INSTALL_DIR/bin/brbr" "$BIN_DIR/brbr"
    
    # Update the update cheat to point to the new installation directory
    sed -i "s|/opt/brbr/|$INSTALL_DIR/|g" "$INSTALL_DIR/cheats/navi.cheat"
    
    print_success "BrBr installed successfully!"
}

validate_installation() {
    print_step "Validating installation..."
    
    # Check if symlink exists
    if [ ! -L "$BIN_DIR/brbr" ]; then
        print_error "Symlink not created at $BIN_DIR/brbr"
    else
        print_success "Symlink created at $BIN_DIR/brbr"
    fi
    
    # Try running brbr
    echo "Testing brbr installation..."
    if "$BIN_DIR/brbr" --help >/dev/null 2>&1; then
        print_success "BrBr is working correctly"
    else
        print_error "BrBr is not working correctly. Try running 'brbr --help' manually for more information."
    fi
}

# Main installation process
echo "╔═══════════════════════════════════════╗"
echo "║             BrBr Installer            ║"
echo "╚═══════════════════════════════════════╝"
echo ""

check_dependencies
check_permissions
install_brbr
validate_installation

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║        Installation Complete          ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "You can now use BrBr by running 'brbr' in your terminal."
echo ""
echo "To access encrypted cheats, first set a password:"
echo "  brbr --set-password"
echo ""
echo "Then access encrypted cheats with:"
echo "  brbr --private"
echo ""
echo "For more options, run:"
echo "  brbr --help"
echo ""
