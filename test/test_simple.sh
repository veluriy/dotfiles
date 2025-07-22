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

# Functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
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

test_symlink() {
    local link_path="$1"
    local target_path="$2"
    local test_name="Symlink: $link_path -> $target_path"
    
    if [ -L "$link_path" ] && [ "$(readlink -f "$link_path")" = "$target_path" ]; then
        pass "$test_name"
    else
        fail "$test_name"
    fi
}

# Main test execution
echo "======================================"
echo "    Simple Dotfiles Test Suite"
echo "======================================"

cd /home/testuser/dotfiles

# Pre-installation tests
info "Testing dotfiles structure..."
test_file_exists "/home/testuser/dotfiles/install.sh"
test_file_exists "/home/testuser/dotfiles/shell/zshrc"
test_file_exists "/home/testuser/dotfiles/fish/config.fish"
test_file_exists "/home/testuser/dotfiles/tmux/tmux.conf"
test_file_exists "/home/testuser/dotfiles/git/gitconfig"

# Test basic installation (symlinks only)
info "Testing symlink creation..."

# Create symlinks manually for testing
ln -sf "/home/testuser/dotfiles/shell/zshrc" ~/.zshrc
mkdir -p ~/.config/fish
ln -sf "/home/testuser/dotfiles/fish/config.fish" ~/.config/fish/config.fish
ln -sf "/home/testuser/dotfiles/tmux/tmux.conf" ~/.tmux.conf
ln -sf "/home/testuser/dotfiles/git/gitconfig" ~/.gitconfig

# Test symlinks
test_symlink "/home/testuser/.zshrc" "/home/testuser/dotfiles/shell/zshrc"
test_symlink "/home/testuser/.config/fish/config.fish" "/home/testuser/dotfiles/fish/config.fish"
test_symlink "/home/testuser/.tmux.conf" "/home/testuser/dotfiles/tmux/tmux.conf"
test_symlink "/home/testuser/.gitconfig" "/home/testuser/dotfiles/git/gitconfig"

# Test configuration content
info "Testing configuration content..."

if grep -q "HISTSIZE=10000" ~/.zshrc; then
    pass "Zsh config contains history settings"
else
    fail "Zsh config missing history settings"
fi

if grep -q 'alias g=' ~/.zshrc; then
    pass "Zsh config contains git aliases"
else
    fail "Zsh config missing git aliases"
fi

if grep -q 'alias g "git"' ~/.config/fish/config.fish; then
    pass "Fish config contains git aliases"
else
    fail "Fish config missing git aliases"
fi

if grep -q "set -g prefix C-j" ~/.tmux.conf; then
    pass "Tmux config contains custom prefix"
else
    fail "Tmux config missing custom prefix"
fi

if grep -q "ptlx@outlook.jp" ~/.gitconfig; then
    pass "Git config contains email"
else
    fail "Git config missing email"
fi

# Summary
echo ""
echo "======================================"
echo "         Test Results"
echo "======================================"
TESTS_TOTAL=$((TESTS_PASSED + TESTS_FAILED))
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