# BrBr

A streamlined, Linux-focused command cheatsheet tool powered by [navi](https://github.com/denisidoro/navi).

## Features

- Fast, fuzzy-searchable command snippets
- Organized by category
- Encrypted cheats with password protection
- Easy installation and updates

## Installation

### Prerequisites

Make sure you have the following dependencies installed:
- bash
- curl
- git
- openssl
- fzf

On Debian/Ubuntu:
```bash
sudo apt install curl git openssl tar file fzf
```

On CentOS/RHEL:
```bash
sudo yum install curl git openssl file tar
# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
```

### Install

```bash
# Clone the repository
git clone https://github.com/mifraburneo/brbr

# Run the installer with sudo (required for /usr/local)
cd brbr
sudo ./install.sh
```

## Usage

```bash
# Show public cheats
brbr

# Access encrypted cheats (requires password)
brbr --private

# Encrypt a new cheat file
brbr --encrypt /path/to/your/cheat/file.cheat

# Set or change the encryption password
brbr --set-password

# Update BrBr
brbr --update
```

## Encrypted Cheats

Encrypted cheats are stored with the `.enc` extension in the `encrypted-cheats` directory of your brbr installation. These files are encrypted and can only be decrypted with the correct password.

### Adding New Encrypted Cheats

1. Create a new cheat file following the [navi cheat format](https://github.com/denisidoro/navi/blob/master/docs/cheat_syntax.md)
2. Encrypt it with `brbr --encrypt your_file.cheat`
3. The encrypted file will be stored in your installation

## Structure of a Cheat File

```cheat
% Category

# Description of command
command --flag value

$ variable: echo -e 'option1\noption2\noption3'
```

## Uninstallation

```bash
sudo ./uninstall.sh
```
