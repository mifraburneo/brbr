#/bin/bash

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
    # Refresh shell for path
    exec "$SHELL"
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

# Add targets
rustup target add x86_64-unknown-linux-gnu
rustup target add x86_64-apple-darwin
rustup target add x86_64-pc-windows-gnu

# Compile code for Linux
cargo build --target="x86_64-unknown-linux-gnu"
if [ $? -eq 0 ]; then
    echo "Compilation for Linux successful!"
else
    echo "Compilation for Linux failed!"
    exit 10
fi

# Compile code for MacOS
cargo build --target="x86_64-apple-darwin"
if [ $? -eq 0 ]; then
    echo "Compilation for MacOS successful!"
else
    echo "Compilation for MacOS failed!"
    exit 11
fi
# Compile code for Windows
cargo build --target="x86_64-pc-windows-gnu"
if [ $? -eq 0 ]; then
    echo "Compilation for Windows successful!"
else
    echo "Compilation for Windows failed!"
    exit 12
fi

cd ..

# Move produced bins to new bin directory

mv navi_repo/target/x86_64-unknown-linux-gnu/debug/navi bins/navi_linux
mv navi_repo/target/x86_64-apple-darwin/debug/navi bins/navi_macos
mv navi_repo/target/x86_64-pc-windows-gnu/debug/navi.exe bins/navi_windows.exe

# Remove navi_repo directory
rm -rf navi_repo

exit 0