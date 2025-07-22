set fish_greeting
fish_vi_key_bindings

alias l "ls"
alias v "nvim"

# cd
alias d "cd ~/dotfiles"
alias p "cd ~/program"
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."


# stack
alias ghci "stack ghci"
alias ghc "stack ghc --"
alias runghc "stack runghc --"


# git
alias g "git"

alias ga "git add"
alias gaa "git add --all"

alias gs "git status"

alias gc "git commit -vm"
alias gac "git add --all && git commit -vm"

alias gb "git branch"
alias gba "git branch -a"
alias gbr "git branch -r"
alias gco "git checkout"
alias gcob "git checkout -b"

alias gf "git fetch"
alias gp "git push"

# docker
alias dp "docker ps"

alias dcu "docker compose up -d"
alias dcd "docker compose down"
alias dcl "docker compose logs -f"
alias dce "docker compose exec"
alias gl "git pull"


alias gd "git diff"


# clear
alias c "clear"


function fish_user_key_bindings
	bind -M insert \cc kill-whole-line repaint
	bind -M insert -m default jk 'commandline -f repaint'
	bind -M insert \cf accept-autosuggestion
end

bind \cd 'exit'
fish_add_path /home/linuxbrew/.linuxbrew/bin
fish_add_path /usr/local/texlive/2023/bin/x86_64-linux
# opam configuration
source /home/ptlx/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true


set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /home/ptlx/.ghcup/bin $PATH # ghcup-env