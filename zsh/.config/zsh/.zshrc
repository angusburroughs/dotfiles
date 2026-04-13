HOMEBREW_PATH="/home/linuxbrew/.linuxbrew"

# ---- Basics ----
setopt autocd
setopt hist_ignore_dups hist_reduce_blanks share_history
HISTFILE="$HOME/.local/share/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

# ---- Homebrew ----
if [[ -x "$HOMEBREW_PATH/bin/brew" ]]; then
  eval "$($HOMEBREW_PATH/bin/brew shellenv)"
fi

# ---- Completion ----
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# ---- Keybinds ----
bindkey -e
# Up/Down search history by prefix
autoload -Uz history-beginning-search-backward history-beginning-search-forward
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# ---- Starship prompt ----
eval "$(starship init zsh)"

# # ---- zoxide (smart cd) ----
# eval "$(zoxide init zsh)"

# ---- fzf (if installed) ----
if command -v fzf >/dev/null; then
  # Common defaults; tweak to taste
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f'
fi

# ---- Atuin (optional; gives a great Ctrl+R) ----
[[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"
if command -v atuin >/dev/null; then
  eval "$(atuin init zsh)"
fi

# ---- Secrets (optional) ----
# keep API keys out of git
[[ -f "$HOME/.secrets/zsh" ]] && source "$HOME/.secrets/zsh"

## PyEnv
export PYENV_ROOT="$HOME/.pyenv"
if [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
  path=("$PYENV_ROOT/bin" $path)
  eval "$("$PYENV_ROOT/bin/pyenv" init - zsh)"
fi

# Path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/scripts:$PATH"
export PATH="$HOME/go/bin:$PATH"

## Windows/WSL things
# Add Docker buildx for multi-platform builds
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
# Prevent .NET from collecting telemetry in containers
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# personal aliases
alias vim=nvim
export HOMEBREW_NO_ENV_HINTS
bindkey -s ^f "tmux-sessionizer\n"
source /home/angusburroughs/tool-worktree-sessionizer.zsh

# tmux things
export TERM="screen-256color"
export COLORTERM=truecolor

# export HISTFILESIZE=1000000
# export HISTSIZE=1000000


# PERL
export PERL5LIB=/home/angusburroughs/workspace/mas-data-warehouse/perllib:$PERL5LIB
eval "$(perl -I/home/angusburroughs/perl5/lib/perl5 -Mlocal::lib)"
typeset -U path PATH
