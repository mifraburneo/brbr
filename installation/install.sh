#/bin/bash
# Path: cheats/installation/install.sh

# Default values
INSTALL_DIR="/opt/brbr"
BIN_DIR="/usr/local/bin"



# Get arguments
while getopts ":h:i:u" opt; do
  case $opt in
    h)
      echo "Usage: $0 [-i] or [-u]" 1>&2
      exit 1 ;;
    i)
        echo "Installing..."
        INSTALL=1 ;;
    u)
        echo "Uninstalling..."
        INSTALL=0 ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1 ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1 ;;
  esac
done


# Install
if [ $INSTALL -eq 1 ]; then

    # Check if the directory already exists
    if [ -d "$INSTALL_DIR" ]; then
        echo "Directory $INSTALL_DIR already exists, run uninstall [-u] first."
        echo ""
        exit 2
    fi

    # Check dependencies: git and curl
    if ! command -v git &> /dev/null; then
        echo "Git could not be found, please install it first."
        # If OS is Linux and package manager is apt, try to install git
        if [ "$(uname)" == "Linux" ] && command -v apt &> /dev/null; then
            echo "OS is Linux and apt package manager is installed!"
            echo "Trying to install git..."
            apt update
            sudo apt install git
        # If OS is Linux and package manager is yum, try to install git
        elif [ "$(uname)" == "Linux" ] && command -v yum &> /dev/null; then
            echo "OS is Linux and yum package manager is installed!"
            echo "Trying to install git..."
            yum update
            sudo yum install git
        fi
        # If OS is MacOS and package manager is brew, try to install git
        elif [ "$(uname)" == "Darwin" ] && command -v brew &> /dev/null; then
            echo "OS is MacOS and brew package manager is installed!"
            echo "Trying to install git..."
            brew update
            brew install git
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
        if [ "$(uname)" == "Linux" ] && command -v apt &> /dev/null; then
            echo "OS is Linux and apt package manager is installed!"
            echo "Trying to install curl..."
            apt update
            sudo apt install curl
        # If OS is Linux and package manager is yum, try to install curl
        elif [ "$(uname)" == "Linux" ] && command -v yum &> /dev/null; then
            echo "OS is Linux and yum package manager is installed!"
            echo "Trying to install curl..."
            yum update
            sudo yum install curl
        fi
        # If OS is MacOS and package manager is brew, try to install curl
        elif [ "$(uname)" == "Darwin" ] && command -v brew &> /dev/null; then
            echo "OS is MacOS and brew package manager is installed!"
            echo "Trying to install curl..."
            brew update
            brew install curl
        # Else, exit
        else
            echo "Please install curl first."
            exit 3
        fi
        echo ""
    fi

    # Create installation directory
    mkdir -p $INSTALL_DIR
  
    # Install fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git "$INSTALL_DIR/fzf"
    /bin/bash "$INSTALL_DIR/fzf/install" --bin
    # Create symbolic link
    ln -s "$INSTALL_DIR/bin/fzf" "$BIN_DIR/fzf"

    # Get custom navi depending on OS:
    # Linux
    if [ "$(uname)" == "Linux" ]; then
    # Download bin file with curl
    https://raw.githubusercontent.com/mifraburneo/brbr/installation/navi_repo/bins/navi-linux -o "$INSTALL_DIR/navi/bin/navi"


    


