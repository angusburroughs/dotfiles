source /opt/homebrew/share/antigen/antigen.zsh

antigen use oh-my-zsh

antigen bundle git

antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle history-substring-search

antigen theme robbyrussell

antigen apply


export EDITOR=/opt/homebrew/bin/nvim

# export GPG_TTY=$(tty)
# export PATH="/opt/homebrew/opt/gnupg@2.2/bin:$PATH"
# export PATH="/Users/angusb/go/bin:$PATH"
#

export PATH="$PATH:$HOME/pathed"

export HOMEBREW_NO_ENV_HINTS
alias vim=nvim

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PATH="$PATH:$HOME/go/bin"


export HISTFILESIZE=1000000
export HISTSIZE=1000000
