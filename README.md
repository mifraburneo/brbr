# Cheats
Bash cheatsheets aimed for navi.

Original navi repo: https://github.com/denisidoro/navi

---------------------

### Installing HomeBrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
#### In Linux installs do:
```
echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.profile
echo 'eval "$(~/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
eval "$(~/.linuxbrew/bin/brew shellenv)"
```
### Installing navi

```
brew install navi
```

#### Optional: Remove default cheats
```
rm -rf ~/.local/share/navi/cheats/*
```

### Adding repo to navi
```
navi repo add https://github.com/mifraburneo/cheats
```

