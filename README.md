# Dotfiles for Ubuntu 22.04 (WSL2)

Personal dotfiles for Ubuntu 22.04 running on WSL2.

## Environment

- **OS**: Ubuntu 22.04.4 LTS (WSL2)
- **Shell**: Zsh 5.8.1
- **Package Manager**: Homebrew (Linuxbrew)
- **Editor**: Neovim
- **Terminal Multiplexer**: Tmux
- **Version Control**: Git with GPG signing

## Installation

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Structure

```
dotfiles/
├── fish/          # Fish shell configuration
├── git/           # Git configuration
├── shell/         # Zsh configuration
├── tmux/          # Tmux configuration
├── install.sh     # Installation script
└── README.md      # This file
```

## Features

- Vi mode in shell
- Extensive aliases for git, docker, and navigation
- Homebrew package management
- Support for multiple programming environments (Haskell, OCaml)
- Fish shell with custom key bindings
- Tmux with custom prefix (C-j) and vim-like navigation

## Manual Steps

After running the install script:

1. Change default shell: `chsh -s $(which zsh)`
2. Log out and back in for changes to take effect
3. For Docker users: Re-login for group membership to apply

## Testing

このdotfilesはDockerを使用した自動テストを含んでいます。

### テストの実行

```bash
# 基本的なテストを実行
./test.sh test

# インタラクティブなテスト環境を開始
./test.sh interactive

# テスト環境をクリーンアップ
./test.sh clean
```

### テスト内容

- dotfilesの構造とファイル存在確認
- シンボリックリンクの作成と検証
- 設定ファイルの内容確認
- エイリアスと設定の動作確認

### テスト環境

- **Base Image**: Ubuntu 22.04
- **Container**: Docker Compose使用
- **Test Runner**: Bash script with color output
- **Isolation**: 各テストは独立したコンテナで実行

## Installed Packages

### Via Homebrew
- fish, neovim, tmux, ripgrep, tree-sitter, node

### Via APT
- build-essential, curl, wget, git, vim, zsh, python3

### Optional
- Docker CE
- GHCup (Haskell)
- OPAM (OCaml)
- TeX Live