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

eval "$($HOMEBREW_PATH/bin/brew shellenv)"
source "$HOMEBREW_PATH/share/antigen/antigen.zsh"

export GPG_TTY=$(tty)

antigen use oh-my-zsh

antigen bundle git

antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle history-substring-search

antigen theme robbyrussell

antigen apply


export EDITOR="$HOMEBREW_PATH/bin/nvim"

# export GPG_TTY=$(tty)
# export PATH="/opt/homebrew/opt/gnupg@2.2/bin:$PATH"
# export PATH="/Users/angusb/go/bin:$PATH"
#

export PATH="$PATH:$HOME/pathed"

export HOMEBREW_NO_ENV_HINTS
alias vim=nvim

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export PATH="$PATH:$HOME/go/bin"


export HISTFILESIZE=1000000
export HISTSIZE=1000000

#source /Users/angusb/.export_api_keys

# export NVM_DIR="$HOME/.nvm"
# [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
# [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

source ~/perl5/perlbrew/etc/bashrc


# Docker command autocompletion
if command -v docker >/dev/null 2>&1; then
  complete -F _docker dk
fi

# Add Docker buildx for multi-platform builds
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Prevent .NET from collecting telemetry in containers
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PATH="$HOME/bin:$PATH"
