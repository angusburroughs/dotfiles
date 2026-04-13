# git worktree + tmux sessioniser for zsh
# Paste into ~/.zshrc or source from another file.
#
# This version is hardened for zsh:
# - bypasses aliases/functions/wrappers with `command git`
# - uses `emulate -L zsh` in every function
# - avoids false "not inside a git repo" checks
#
# Commands:
#   wt <branch>        use existing branch/remote branch worktree at ../<branch> and cd into it
#   wt -b <branch>     create a new branch worktree at ../<branch> and cd into it
#   wtl                list worktrees
#   wtp                prune stale worktree metadata
#   wts [path|name|.] sessionise a worktree in tmux, or choose with fzf
#   wtx <branch>       use existing branch/remote branch worktree if needed, then sessionise it
#   wtx -b <branch>    create a new branch worktree if needed, then sessionise it
#   wtr <path|name>    kill tmux session and remove the worktree
#   ws                 alias for wts

__wt_git() {
  emulate -L zsh
  command git "$@"
}

__wt_in_repo() {
  emulate -L zsh
  local dir
  dir="${1:-$PWD}"
  __wt_git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

__wt_repo_root() {
  emulate -L zsh
  local dir
  dir="${1:-$PWD}"
  __wt_git -C "$dir" rev-parse --show-toplevel 2>/dev/null
}

__wt_worktree_parent() {
  emulate -L zsh
  local repo_root

  repo_root="$(__wt_repo_root "${1:-$PWD}")" || return 1
  print -r -- "${repo_root:h}"
}

__wt_main_worktree() {
  emulate -L zsh
  local dir

  dir="${1:-$PWD}"
  __wt_git -C "$dir" worktree list --porcelain | awk '
    /^worktree / { print substr($0,10); exit }
  '
}

__wt_copy_agents_md() {
  emulate -L zsh
  local dir worktree_path main_worktree source_path dest_path

  dir="$1"
  worktree_path="$2"
  main_worktree="$(__wt_main_worktree "$dir")" || return 1
  source_path="$main_worktree/AGENTS.md"
  dest_path="$worktree_path/AGENTS.md"

  [[ -f "$source_path" ]] || return 0
  command cp "$source_path" "$dest_path"
}

__wt_fetch_refs() {
  emulate -L zsh
  local dir

  dir="${1:-$PWD}"
  __wt_git -C "$dir" fetch --prune --all
}

__wt_has_local_branch() {
  emulate -L zsh
  local dir name

  dir="$1"
  name="$2"
  __wt_git -C "$dir" show-ref --verify --quiet "refs/heads/$name"
}

__wt_remote_branch_ref() {
  emulate -L zsh
  local dir name match ref branch_name
  local -a remote_refs

  dir="$1"
  name="$2"

  if __wt_git -C "$dir" show-ref --verify --quiet "refs/remotes/origin/$name"; then
    print -r -- "origin/$name"
    return 0
  fi

  remote_refs=("${(@f)$(__wt_git -C "$dir" for-each-ref --format='%(refname:short)' refs/remotes 2>/dev/null)}")

  for ref in "${remote_refs[@]}"; do
    [[ "$ref" == */HEAD ]] && continue
    branch_name="${ref#*/}"

    if [[ "$branch_name" == "$name" ]]; then
      if [[ -n "$match" ]]; then
        print -u2 "branch '$name' exists on multiple remotes; create it explicitly with -b or create a local branch first"
        return 2
      fi

      match="$ref"
    fi
  done

  [[ -n "$match" ]] || return 1
  print -r -- "$match"
}

__wt_add_worktree() {
  emulate -L zsh
  local dir name worktree_path remote_ref create_branch

  dir="$1"
  name="$2"
  worktree_path="$3"
  create_branch="$4"

  __wt_fetch_refs "$dir" || return 1

  if [[ "$create_branch" == 1 ]]; then
    __wt_git -C "$dir" worktree add -b "$name" "$worktree_path" || return 1
    __wt_copy_agents_md "$dir" "$worktree_path"
    return $?
  fi

  if __wt_has_local_branch "$dir" "$name"; then
    __wt_git -C "$dir" worktree add "$worktree_path" "$name" || return 1
    __wt_copy_agents_md "$dir" "$worktree_path"
    return $?
  fi

  remote_ref="$(__wt_remote_branch_ref "$dir" "$name")"
  case $? in
    0)
      __wt_git -C "$dir" worktree add --track -b "$name" "$worktree_path" "$remote_ref" || return 1
      __wt_copy_agents_md "$dir" "$worktree_path"
      ;;
    1)
      print -u2 "branch '$name' does not exist locally or on any fetched remote; use -b to create it"
      return 1
      ;;
    *)
      return 1
      ;;
  esac
}

wt() {
  emulate -L zsh
  local name parent_dir worktree_path create_branch

  create_branch=0
  if [[ "$1" == "-b" ]]; then
    create_branch=1
    shift
  fi

  name="$1"
  if [[ -z "$name" ]]; then
    print -u2 "usage: wt [-b] <branch-name>"
    return 1
  fi

  if ! __wt_in_repo "$PWD"; then
    print -u2 "wt: not inside a git repository"
    return 1
  fi

  parent_dir="$(__wt_worktree_parent "$PWD")" || return 1
  worktree_path="$parent_dir/$name"
  __wt_add_worktree "$PWD" "$name" "$worktree_path" "$create_branch" && builtin cd "$worktree_path"
}

wtl() {
  emulate -L zsh
  __wt_git worktree list
}

wtp() {
  emulate -L zsh
  __wt_git worktree prune
}

__wts_worktree_paths() {
  emulate -L zsh
  __wt_git worktree list --porcelain | awk '
    /^worktree / { path=substr($0,10) }
    /^$/ { if (path) print path; path="" }
    END { if (path) print path }
  '
}

__wts_session_name() {
  emulate -L zsh
  local worktree_path repo_root repo_name branch_name fallback name

  worktree_path="$1"
  repo_root="$(__wt_git -C "$worktree_path" rev-parse --show-toplevel 2>/dev/null)" || return 1
  repo_name="${repo_root:t}"
  branch_name="$(__wt_git -C "$worktree_path" branch --show-current 2>/dev/null)"
  fallback="${worktree_path:t}"

  if [[ -n "$branch_name" ]]; then
    name="${repo_name}__${branch_name}"
  else
    name="${repo_name}__${fallback}"
  fi

  name="${name//\//_}"
  name="${name//./_}"
  print -r -- "$name"
}

__wts_has_window() {
  emulate -L zsh
  local session_name window_name

  session_name="$1"
  window_name="$2"
  tmux list-windows -t "$session_name" -F '#{window_name}' 2>/dev/null | command grep -Fxq -- "$window_name"
}

__wts_ensure_window() {
  emulate -L zsh
  local session_name worktree_path window_name window_cmd

  session_name="$1"
  worktree_path="$2"
  window_name="$3"
  window_cmd="$4"

  if ! __wts_has_window "$session_name" "$window_name"; then
    tmux new-window -d -t "$session_name" -c "$worktree_path" -n "$window_name"
    [[ -n "$window_cmd" ]] && tmux send-keys -t "${session_name}:$window_name" "$window_cmd" C-m
  fi
}

__wts_open_session() {
  emulate -L zsh
  local worktree_path session_name created_session git_cmd first_window_name first_window_cmd selected_window

  worktree_path="$1"

  if [[ ! -d "$worktree_path" ]]; then
    print -u2 "__wts_open_session: no such directory: $worktree_path"
    return 1
  fi

  if ! command -v tmux >/dev/null 2>&1; then
    print -u2 "wts: tmux is not installed"
    return 1
  fi

  session_name="$(__wts_session_name "$worktree_path")" || return 1
  created_session=0

  if command -v lazygit >/dev/null 2>&1; then
    git_cmd="lazygit"
  else
    git_cmd="git status"
  fi

  if command -v opencode >/dev/null 2>&1; then
    first_window_name="opencode"
    first_window_cmd="opencode"
  elif command -v nvim >/dev/null 2>&1; then
    first_window_name="nvim"
    first_window_cmd="nvim"
  elif [[ -n "$git_cmd" ]]; then
    first_window_name="git"
    first_window_cmd="$git_cmd"
  else
    first_window_name="shell"
    first_window_cmd=""
  fi

  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new-session -d -s "$session_name" -c "$worktree_path" -n "$first_window_name"
    [[ -n "$first_window_cmd" ]] && tmux send-keys -t "${session_name}:$first_window_name" "$first_window_cmd" C-m
    created_session=1
  fi

  if command -v nvim >/dev/null 2>&1; then
    __wts_ensure_window "$session_name" "$worktree_path" nvim nvim
  fi

  if command -v opencode >/dev/null 2>&1; then
    __wts_ensure_window "$session_name" "$worktree_path" opencode opencode
  fi

  __wts_ensure_window "$session_name" "$worktree_path" git "$git_cmd"

  if __wts_has_window "$session_name" shell; then
    if (( created_session )); then
      tmux send-keys -t "${session_name}:shell" "clear" C-m
    fi
  else
    tmux new-window -d -t "$session_name" -c "$worktree_path" -n shell
    tmux send-keys -t "${session_name}:shell" "clear" C-m
  fi

  if __wts_has_window "$session_name" opencode; then
    selected_window="opencode"
  elif __wts_has_window "$session_name" nvim; then
    selected_window="nvim"
  elif __wts_has_window "$session_name" git; then
    selected_window="git"
  else
    selected_window="shell"
  fi

  tmux select-window -t "${session_name}:$selected_window" 2>/dev/null || true

  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$session_name"
  else
    tmux attach-session -t "$session_name"
  fi
}

wts() {
  emulate -L zsh
  local target parent_dir worktree_path

  target="${1:-}"

  if [[ -z "$target" ]]; then
    if ! __wt_in_repo "$PWD"; then
      print -u2 "wts: not inside a git repository"
      return 1
    fi

    if command -v fzf >/dev/null 2>&1; then
      worktree_path="$(__wts_worktree_paths | fzf --prompt='Worktree > ' --height=40% --reverse)"
      [[ -z "$worktree_path" ]] && return 0
    else
      print -u2 "wts: fzf not installed"
      print -u2 "available worktrees:"
      __wts_worktree_paths >&2
      print -u2 ""
      print -u2 "pass a path explicitly, or install fzf"
      return 1
    fi
  elif [[ "$target" == "." ]]; then
    worktree_path="$PWD"
  elif [[ -d "$target" ]]; then
    worktree_path="$(builtin cd "$target" && pwd)"
  else
    if __wt_in_repo "$PWD"; then
      parent_dir="$(__wt_worktree_parent "$PWD")" || return 1

      if [[ -d "$parent_dir/$target" ]]; then
        worktree_path="$(builtin cd "$parent_dir/$target" && pwd)"
      else
        print -u2 "wts: no such worktree path: $target"
        return 1
      fi
    else
      print -u2 "wts: no such worktree path: $target"
      return 1
    fi
  fi

  if ! __wt_in_repo "$worktree_path"; then
    print -u2 "wts: target is not a git worktree: $worktree_path"
    return 1
  fi

  __wts_open_session "$worktree_path"
}

wtx() {
  emulate -L zsh
  local name parent_dir worktree_path create_branch

  create_branch=0
  if [[ "$1" == "-b" ]]; then
    create_branch=1
    shift
  fi

  name="$1"
  if [[ -z "$name" ]]; then
    print -u2 "usage: wtx [-b] <branch-name>"
    return 1
  fi

  if ! __wt_in_repo "$PWD"; then
    print -u2 "wtx: not inside a git repository"
    return 1
  fi

  parent_dir="$(__wt_worktree_parent "$PWD")" || return 1
  worktree_path="$parent_dir/$name"

  if [[ ! -d "$worktree_path" ]]; then
    __wt_add_worktree "$PWD" "$name" "$worktree_path" "$create_branch" || return 1
  fi

  __wts_open_session "$(builtin cd "$worktree_path" && pwd)"
}

wtr() {
  emulate -L zsh
  local target target_path abs_path main_worktree parent_dir session_name

  target="$1"
  if [[ -z "$target" ]]; then
    print -u2 "usage: wtr <branch-name-or-path>"
    return 1
  fi

  if [[ -d "$target" ]]; then
    target_path="$target"
  else
    if __wt_in_repo "$PWD"; then
      parent_dir="$(__wt_worktree_parent "$PWD")" || return 1

      if [[ -d "$parent_dir/$target" ]]; then
        target_path="$parent_dir/$target"
      else
        print -u2 "wtr: no such worktree path: $target"
        return 1
      fi
    else
      print -u2 "wtr: no such worktree path: $target"
      return 1
    fi
  fi

  abs_path="$(builtin cd "$target_path" && pwd)"

  if ! __wt_in_repo "$abs_path"; then
    print -u2 "wtr: target is not a git worktree: $abs_path"
    return 1
  fi

  main_worktree="$(__wt_main_worktree "$abs_path")" || return 1
  session_name="$(__wts_session_name "$abs_path" 2>/dev/null)"

  if command -v tmux >/dev/null 2>&1 && [[ -n "$session_name" ]]; then
    tmux kill-session -t "$session_name" 2>/dev/null || true
  fi

  __wt_git -C "$main_worktree" worktree remove "$abs_path"
}

alias ws='wts'
