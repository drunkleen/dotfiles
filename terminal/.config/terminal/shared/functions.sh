# Load shared, shell-agnostic functions. Portable across bash and zsh.
SHELL_SHARED_DIR="${SHELL_SHARED_DIR:-$HOME/.config/terminal/shared}"

for _sh_functions in "$SHELL_SHARED_DIR"/functions.d/*; do
  [[ -f "$_sh_functions" ]] && source "$_sh_functions"
done
unset _sh_functions
