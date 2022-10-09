#/bin/bash

rm -rf navi_repo
git clone https://github.com/denisidoro/navi navi_repo
rm -rf navi_repo/.git*

mkdir -p navi_repo/bins

# Check if cargo is installed, else install it
if ! command -v cargo &> /dev/null; then
    echo "Cargo could not be found, please install it first."
    # If OS is Linux and package manager is apt, try to install cargo
    if [ "$(uname)" == "Linux" ] && command -v apt &> /dev/null; then
        echo "OS is Linux and apt package manager is installed!"
        echo "Trying to install cargo..."
        apt update
        sudo apt install cargo
    else
        echo "Please install cargo first."
        exit 3
    fi
    echo ""
fi

# Compile code for Linux
cd navi_repo
cargo build --release
