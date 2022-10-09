#/bin/bash

OS=()
help() {
  cat << EOF
  Usage: $0 -linux -macos -windows
EOF
}

if [ $# -eq 0 ]; then
  help
  exit 1
fi

# Get mandatory arguments -linux, -macos, -windows and help optional
while [ $# -gt 0 ]; do
  case "$1" in
    -linux)
      OS+=("linux") ;;
    -macos)
      OS+=("macos") ;;
    -windows)
      OS+=("windows") ;;
    -help)
      help
      exit 0 ;;
    *)
      echo "Invalid option: $1"
      help
      exit 1 ;;
  esac
  shift
done


git clone https://github.com/denisidoro/navi navi_repo

echo "" > navi_repo/docs/navi.cheat 

# Check if cargo/rustup is installed installed, else install it
if ! command -v cargo &> /dev/null; then
    echo "Rustup could not be found, trying to install..."
    # Try to install rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    if [ $? -ne 0 ]; then
        echo "Failed to install rustup, please install it first."
        exit 3
    fi
    source "$HOME/.cargo/env"    
fi
    echo ""

# If OS is Linux
if [ "$(uname)" == "Linux" ]; then
    # Modifiy navi_repo/src/filesystem.rs
    sed -i 's/BaseDirs::new().ok_or_else(|| anyhow!("Unable to get base dirs"))?;/"\/opt\/brbr";/g' navi_repo/src/filesystem.rs
    sed -i 's/base_dirs.data_dir()/base_dirs/g' navi_repo/src/filesystem.rs
    sed -i 's/base_dirs.config_dir()/base_dirs/g' navi_repo/src/filesystem.rs
# If OS is MacOS
elif [ "$(uname)" == "Darwin" ]; then
    # Modifiy navi_repo/src/filesystem.rs
    sed -i '' 's/BaseDirs::new().ok_or_else(|| anyhow!("Unable to get base dirs"))?;/"\/opt\/brbr";/g' navi_repo/src/filesystem.rs
    sed -i '' 's/base_dirs.data_dir()/base_dirs/g' navi_repo/src/filesystem.rs
    sed -i '' 's/base_dirs.config_dir()/base_dirs/g' navi_repo/src/filesystem.rs
fi

cd navi_repo

for os in "${OS[@]}"; do
    echo "Building for $os..."
    if [ "$os" == "linux" ]; then
        rustup target add x86_64-unknown-linux-musl
        # Compile code for Linux
        cargo build --target="x86_64-unknown-linux-musl"
        if [ $? -eq 0 ]; then
            echo "Compilation for Linux successful!"
        else
            echo "Compilation for Linux failed!"
            exit 10
        fi
    elif [ "$os" == "macos" ]; then
        rustup target add x86_64-apple-darwin
        # Compile code for MacOS
        cargo build --target="x86_64-apple-darwin"
        if [ $? -eq 0 ]; then
            echo "Compilation for MacOS successful!"
        else
            echo "Compilation for MacOS failed!"
            exit 11
        fi
    elif [ "$os" == "windows" ]; then
        rustup target add x86_64-pc-windows-gnu
        # Compile code for Windows
        cargo build --target="x86_64-pc-windows-gnu"
        if [ $? -eq 0 ]; then
            echo "Compilation for Windows successful!"
        else
            echo "Compilation for Windows failed!"
            exit 12
        fi
    fi
    echo ""
done

cd ..

# Move produced bins to new bin directory

rm -rf bins
mkdir bins

for os in "${OS[@]}"; do
    if [ "$os" == "linux" ]; then
        mv navi_repo/target/x86_64-unknown-linux-musl/debug/navi bins/navi-linux
        chmod 770 bins/navi-linux
    elif [ "$os" == "macos" ]; then
        mv navi_repo/target/x86_64-apple-darwin/debug/navi bins/navi-macos
        chmod 770 bins/navi-macos
    elif [ "$os" == "windows" ]; then
        mv navi_repo/target/x86_64-pc-windows-gnu/debug/navi.exe bins/navi-windows.exe
    fi
done

# Remove navi_repo directory
rm -rf navi_repo

exit 0