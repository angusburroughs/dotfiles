source /opt/homebrew/share/antigen/antigen.zsh

antigen use oh-my-zsh

antigen bundle git

antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle history-substring-search

antigen theme robbyrussell

antigen apply


export GPG_TTY=$(tty)
export PATH="/opt/homebrew/opt/gnupg@2.2/bin:$PATH"
export PATH="/Users/angusb/Library/Python/3.8/bin:$PATH"
export PATH="/Users/angusb/go/bin:$PATH"
export PATH="/Users/angusb/path-scripts:$PATH"

export TERM=xterm-256color
export HOMEBREW_NO_ENV_HINTS
alias vim=nvim

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# OCTAVIA CLI 0.40.27
# OCTAVIA_ENV_FILE=/Users/angusb/.octavia

# # OCTAVIA CLI 0.40.27
# OCTAVIA_ENV_FILE=/Users/angusb/.octavia
# export OCTAVIA_ENABLE_TELEMETRY=False
# alias octavia="docker run -i --rm -v \$(pwd):/home/octavia-project --network host --env-file \${OCTAVIA_ENV_FILE} --user \$(id -u):\$(id -g) airbyte/octavia-cli:0.40.32"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
