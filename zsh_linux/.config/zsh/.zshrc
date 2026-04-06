# OS conditionals here
# Determine the OS and set the Homebrew path accordingly
case "$(uname -s)" in
  Darwin)
    # macOS
    HOMEBREW_PATH="/opt/homebrew"
    ;;
  Linux)
    # Linux (including WSL)
    HOMEBREW_PATH="/home/linuxbrew/.linuxbrew"
    ;;
  *)
    # Default
    HOMEBREW_PATH="/usr/local"
    echo "Unknown OS, defaulting to $HOMEBREW_PATH for Homebrew"
    ;;
esac


export GPG_TTY=$(tty)

# export EDITOR="$HOMEBREW_PATH/bin/nvim"
export PYENV_ROOT="$HOME/.pyenv"
path=($PYENV_ROOT/bin(N) $path)
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Single adds (after pyenv, before .local/bin)
path+=($HOME/scripts $HOME/go/bin $HOME/bin(N))

export HOMEBREW_NO_ENV_HINTS
alias vim=nvim

export TERM="screen-256color"
export COLORTERM=truecolor

export HISTFILESIZE=1000000
export HISTSIZE=1000000

#source /Users/angusb/.export_api_keys

# export NVM_DIR="$HOME/.nvm"
# [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
# [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# source ~/perl5/perlbrew/etc/bashrc

# Docker command autocompletion
if command -v docker >/dev/null 2>&1; then
  complete -F _docker dk
fi

# Add Docker buildx for multi-platform builds
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Prevent .NET from collecting telemetry in containers
export DOTNET_CLI_TELEMETRY_OPTOUT=1
# . "$HOME/.local/bin/env"

bindkey -s ^f "tmux-sessionizer\n"

# eval "$($HOMEBREW_PATH/bin/brew shellenv)"
source "$HOMEBREW_PATH/share/antigen/antigen.zsh"

antigen use oh-my-zsh
antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle history-substring-search
antigen theme robbyrussell
antigen apply

# dedupe path
typeset -U path path
