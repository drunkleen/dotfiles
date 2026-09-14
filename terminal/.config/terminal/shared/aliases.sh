# Load shared, shell-agnostic aliases. Portable across bash and zsh.
SHELL_SHARED_DIR="${SHELL_SHARED_DIR:-$HOME/.config/terminal/shared}"

for _sh_aliases in "$SHELL_SHARED_DIR"/aliases.d/*; do
  [[ -f "$_sh_aliases" ]] && source "$_sh_aliases"
done
unset _sh_aliases
