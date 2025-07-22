#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_TOTAL++))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
    ((TESTS_TOTAL++))
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    info "Running test: $test_name"
    
    if eval "$test_command" &> /dev/null; then
        pass "$test_name"
    else
        fail "$test_name"
    fi
}

test_file_exists() {
    local file_path="$1"
    local test_name="File exists: $file_path"
    
    if [ -f "$file_path" ] || [ -L "$file_path" ]; then
        pass "$test_name"
    else
        fail "$test_name"
    fi
}

test_command_exists() {
    local command="$1"
    local test_name="Command exists: $command"
    
    if command -v "$command" &> /dev/null; then
        pass "$test_name"
    else
        fail "$test_name"
    fi
}

test_symlink() {
    local link_path="$1"
    local target_path="$2"
    local test_name="Symlink correct: $link_path -> $target_path"
    
    if [ -L "$link_path" ] && [ "$(readlink -f "$link_path")" = "$target_path" ]; then
        pass "$test_name"
    else
        fail "$test_name"
    fi
}

# Main test execution
echo "======================================"
echo "       Dotfiles Test Suite"
echo "======================================"

# Pre-installation tests
info "Pre-installation checks..."
test_file_exists "/home/testuser/dotfiles/install.sh"
test_file_exists "/home/testuser/dotfiles/shell/zshrc"
test_file_exists "/home/testuser/dotfiles/fish/config.fish"
test_file_exists "/home/testuser/dotfiles/tmux/tmux.conf"
test_file_exists "/home/testuser/dotfiles/git/gitconfig"

# Run installation (non-interactive)
info "Running dotfiles installation..."
cd /home/testuser/dotfiles

# Create a non-interactive version of the install script
cat > install_test.sh << 'EOF'
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

# Install Homebrew (Linuxbrew) - Skip for test environment
info "Skipping Homebrew installation in test environment"

# Create symlinks for dotfiles
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

info "Creating symbolic links..."

# Shell
ln -sf "$DOTFILES_DIR/shell/zshrc" ~/.zshrc

# Fish - create config directory first
mkdir -p ~/.config/fish
ln -sf "$DOTFILES_DIR/fish/config.fish" ~/.config/fish/config.fish

# Tmux
ln -sf "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf

# Git
ln -sf "$DOTFILES_DIR/git/gitconfig" ~/.gitconfig

info "Basic setup complete!"
EOF

chmod +x install_test.sh

# Run the test installation
if ./install_test.sh; then
    pass "Installation script executed successfully"
else
    fail "Installation script failed"
fi

# Post-installation tests
info "Post-installation checks..."

# Test symlinks
test_symlink "/home/testuser/.zshrc" "/home/testuser/dotfiles/shell/zshrc"
test_symlink "/home/testuser/.config/fish/config.fish" "/home/testuser/dotfiles/fish/config.fish"
test_symlink "/home/testuser/.tmux.conf" "/home/testuser/dotfiles/tmux/tmux.conf"
test_symlink "/home/testuser/.gitconfig" "/home/testuser/dotfiles/git/gitconfig"

# Test installed commands
test_command_exists "git"
test_command_exists "vim"
test_command_exists "zsh"
test_command_exists "tmux"
test_command_exists "python3"

# Test configuration file contents
info "Testing configuration content..."

# Test zsh config contains expected content
if grep -q "HISTSIZE=10000" ~/.zshrc; then
    pass "Zsh config contains history settings"
else
    fail "Zsh config missing history settings"
fi

if grep -q "alias g=" ~/.zshrc; then
    pass "Zsh config contains git aliases"
else
    fail "Zsh config missing git aliases"
fi

# Test fish config
if grep -q "alias g \"git\"" ~/.config/fish/config.fish; then
    pass "Fish config contains git aliases"
else
    fail "Fish config missing git aliases"
fi

# Test tmux config
if grep -q "set -g prefix C-j" ~/.tmux.conf; then
    pass "Tmux config contains custom prefix"
else
    fail "Tmux config missing custom prefix"
fi

# Test git config
if grep -q "ptlx@outlook.jp" ~/.gitconfig; then
    pass "Git config contains email"
else
    fail "Git config missing email"
fi

# Test shell functionality (basic alias test)
info "Testing shell functionality..."

# Source the zsh config and test an alias
if bash -c ". ~/.zshrc && alias g" &> /dev/null; then
    pass "Zsh aliases loaded correctly"
else
    fail "Zsh aliases not working"
fi

# Summary
echo ""
echo "======================================"
echo "         Test Results"
echo "======================================"
echo -e "Total tests: ${BLUE}$TESTS_TOTAL${NC}"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed! ✗${NC}"
    exit 1
fi