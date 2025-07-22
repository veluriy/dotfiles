#!/bin/bash

set -e

echo "Ubuntu (WSL2) Environment Setup Script"
echo "======================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Functions
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Update and install base packages
info "Updating package lists..."
sudo apt update

info "Installing essential packages..."
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    zsh \
    tmux \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv

# Install Homebrew (Linuxbrew)
if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    info "Homebrew already installed"
fi

# Install packages via Homebrew
info "Installing Homebrew packages..."
brew install \
    fish \
    neovim \
    tmux \
    ripgrep \
    tree-sitter \
    node

# Create symlinks for dotfiles
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

info "Creating symbolic links..."

# Shell
ln -sf "$DOTFILES_DIR/shell/zshrc" ~/.zshrc

# Fish
mkdir -p ~/.config/fish
ln -sf "$DOTFILES_DIR/fish/config.fish" ~/.config/fish/config.fish

# Tmux
ln -sf "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf

# Git
ln -sf "$DOTFILES_DIR/git/gitconfig" ~/.gitconfig

# Docker installation (optional)
read -p "Install Docker? (y/N): " install_docker
if [[ $install_docker =~ ^[Yy]$ ]]; then
    info "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    warn "Please log out and back in for Docker group changes to take effect"
fi

# Programming language environments (optional)
read -p "Install GHCup (Haskell)? (y/N): " install_ghcup
if [[ $install_ghcup =~ ^[Yy]$ ]]; then
    info "Installing GHCup..."
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
fi

read -p "Install OPAM (OCaml)? (y/N): " install_opam
if [[ $install_opam =~ ^[Yy]$ ]]; then
    info "Installing OPAM..."
    sudo apt install -y opam
    opam init --disable-sandboxing
fi

# TeX Live (optional)
read -p "Install TeX Live? (y/N): " install_tex
if [[ $install_tex =~ ^[Yy]$ ]]; then
    warn "TeX Live installation is large and may take a while..."
    wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
    tar -xzf install-tl-unx.tar.gz
    cd install-tl-* && sudo ./install-tl
    cd .. && rm -rf install-tl*
fi

info "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Log out and back in for all changes to take effect"
echo "2. Change your default shell to zsh: chsh -s $(which zsh)"
echo "3. Open a new terminal and enjoy your configured environment!"