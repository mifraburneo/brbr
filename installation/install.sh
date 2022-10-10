#/bin/bash
# Path: cheats/installation/install.sh

# Default values
INSTALL_DIR="/opt/brbr"
BIN_DIR="/usr/local/bin"

INSTALL="0"
UNINSTALL="0"

if [ $# -eq 0 ]; then
  echo "Usage: $0 -i OR $0 -u"
  echo "Try '$0 -h' for more information."
  exit 1
fi

# Get arguments
while getopts "iuh" flag; do
    case $flag in
        i) INSTALL="1"
        echo "Installing brbr..." ;;
        u) UNINSTALL="1"
        echo "Uninstalling brbr..." ;;
        h) cat << EOF
        Usage: $0 -i OR -u OR -h
        -i: Install brbr
        -u: Uninstall brbr
        -h: Show this help
EOF
        exit 0 ;;
    esac
done

############################################
################ Install ###################
############################################

if [ $INSTALL = "1" ]; then

    # Check if the directory already exists
    if [ -d "$INSTALL_DIR/fzf" ]; then
        if [ -d "$INSTALL_DIR/navi" ]; then
            echo "Directory $INSTALL_DIR already exists, run uninstall [-u] first."
            echo ""
            exit 2
        fi
    fi

    # Check dependencies: git and curl
    if ! command -v git &> /dev/null; then
        echo "Git could not be found, please install it first."
        # If OS is Linux and package manager is apt, try to install git
        if [ "$(uname)" = "Linux" ] && command -v apt &> /dev/null; then
            echo "OS is Linux and apt package manager is installed!"
            echo "Trying to install git..."
            apt update
            sudo apt install git -y
        # If OS is Linux and package manager is yum, try to install git
        elif [ "$(uname)" = "Linux" ] && command -v yum &> /dev/null; then
            echo "OS is Linux and yum package manager is installed!"
            echo "Trying to install git..."
            yum update
            sudo yum install git -y
        # If OS is MacOS and package manager is brew, try to install git
        elif [ "$(uname)" = "Darwin" ] && command -v brew &> /dev/null; then
            echo "OS is MacOS and brew package manager is installed!"
            echo "Trying to install git..."
            brew update
            brew install git -y
        # Else, exit
        else
            echo "Please install git first."
            exit 3
        fi
        echo ""
    fi
    if ! command -v curl &> /dev/null; then
        echo "Curl could not be found, please install it first."
        # If OS is Linux and package manager is apt, try to install curl
        if [ "$(uname)" = "Linux" ] && command -v apt &> /dev/null; then
            echo "OS is Linux and apt package manager is installed!"
            echo "Trying to install curl..."
            apt update
            sudo apt install curl -y
        # If OS is Linux and package manager is yum, try to install curl
        elif [ "$(uname)" = "Linux" ] && command -v yum &> /dev/null; then
            echo "OS is Linux and yum package manager is installed!"
            echo "Trying to install curl..."
            yum update
            sudo yum install curl -y
        # If OS is MacOS and package manager is brew, try to install curl
        elif [ "$(uname)" = "Darwin" ] && command -v brew &> /dev/null; then
            echo "OS is MacOS and brew package manager is installed!"
            echo "Trying to install curl..."
            brew update
            brew install curl -y
        # Else, exit
        else
            echo "Please install curl first."
            exit 3
        fi
        echo ""
    fi

    # Install fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git "$INSTALL_DIR/fzf"
    /bin/bash "$INSTALL_DIR/fzf/install" --bin
    # Create symbolic link
    ln -s "$INSTALL_DIR/fzf/bin/fzf" "$BIN_DIR/fzf"

    # Linux
    if [ "$(uname)" = "Linux" ]; then
    mkdir -p "$INSTALL_DIR/navi/bin"

    cp bins/navi-linux "$INSTALL_DIR/navi/bin/navi"
    chmod 754 "$INSTALL_DIR/navi/bin/navi"

    # Create symbolic link
    ln -s "$INSTALL_DIR/navi/bin/navi" "$BIN_DIR/brbr"
    fi

    echo ""
    echo "Installation complete!"
    echo "Restart your terminal to apply changes."
    echo ""
    exit 0
fi

############################################
################ Uninstall #################
############################################

if [ $UNINSTALL = "1" ]; then

    # Remove symbolic link
    rm -f "$BIN_DIR/brbr"
    rm -f "$BIN_DIR/fzf"

    # Remove directory
    rm -rf "$INSTALL_DIR"

    sleep 2
    echo ""
    echo "Uninstall complete!"
    echo "Restart your terminal to apply changes."
    echo ""
    exit 0
fi
    


    


