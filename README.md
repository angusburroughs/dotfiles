Uses GNU Stow. Essentially just symlinks these package directories into the target home directory.

Usage:
`stow <package>` (`-t DIR` to target somewhere else)

Current zsh layout:
- `zsh/.zshenv` sets `ZDOTDIR=$HOME/.config/zsh`
- `zsh/.config/zsh/.zshrc` is the active interactive zsh config
- `zsh/.config/zsh/.zprofile` is the active login config
- `zsh/tool-worktree-sessionizer.zsh` is sourced from the zshrc

Example:
`stow zsh`

Useful link: https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html
