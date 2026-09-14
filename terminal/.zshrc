# Add your own exports, aliases, and functions here.
#
# Shared, shell-agnostic config (theme + aliases + functions)
export SHELL_SHARED_DIR="$HOME/.config/terminal/shared"
source "$SHELL_SHARED_DIR/theme.sh"
source "$SHELL_SHARED_DIR/aliases.sh"
source "$SHELL_SHARED_DIR/functions.sh"

# Zsh entry point. All real config lives in ~/.config/terminal/zsh/.
[[ -f "$HOME/.config/terminal/zsh/init.zsh" ]] && source "$HOME/.config/terminal/zsh/init.zsh"

eval $(thefuck --alias)
