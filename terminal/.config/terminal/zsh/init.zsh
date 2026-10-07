# ============================================================
# Zsh Configuration
# ============================================================


# ---- Zsh options ------------------------------------------------------------

setopt AUTO_CD                 # cd to a directory by typing its path
setopt AUTO_PUSHD              # cd pushes previous directory to dir stack
setopt PUSHD_IGNORE_DUPS       # don't keep duplicate directories in stack

setopt EXTENDED_HISTORY        # save timestamps and duration
setopt HIST_IGNORE_ALL_DUPS    # remove older duplicate commands
setopt HIST_IGNORE_SPACE       # ignore commands starting with a space
setopt HIST_FIND_NO_DUPS       # don't show duplicates while searching
setopt HIST_REDUCE_BLANKS      # remove unnecessary blanks before saving
setopt HIST_SAVE_NO_DUPS       # don't write duplicate entries
setopt SHARE_HISTORY           # share history between Zsh sessions

setopt NO_BEEP
setopt PROMPT_SUBST
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END


# ---- History ----------------------------------------------------------------

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000


# ---- Zinit ------------------------------------------------------------------

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  mkdir -p "${ZINIT_HOME:h}"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"


# ---- Omarchy environment ----------------------------------------------------

[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] &&
  source /usr/share/omarchy/default/bash/env-bootstrap


# ---- Rust toolchain ---------------------------------------------------------

[[ -f "$HOME/.cargo/env" ]] &&
  source "$HOME/.cargo/env"


# ---- Completion plugins -----------------------------------------------------
# Load completion definitions BEFORE compinit.

zinit light zsh-users/zsh-completions


# ---- Completion system ------------------------------------------------------

fpath=(
  "$HOME/.config/terminal/zsh/completions"
  $fpath
)

autoload -Uz compinit
compinit

# Case-insensitive + partial completion
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'l:|=* r:|=*'


# ---- Interactive plugins ----------------------------------------------------

# Better TAB completion using fzf
zinit light Aloxaf/fzf-tab

# Inline suggestions from history
zinit light zsh-users/zsh-autosuggestions

# Search history based on what is currently typed
zinit light zsh-users/zsh-history-substring-search

# Oh My Zsh Git aliases + helpers
zinit snippet OMZP::git

# Press ESC twice to prepend sudo
zinit snippet OMZP::sudo

# Universal archive extraction with `x`
zinit snippet OMZP::extract

# Keep syntax highlighting near the end of plugin loading
zinit light zsh-users/zsh-syntax-highlighting


# ---- Keybindings ------------------------------------------------------------

# Use Emacs-style editing
bindkey -e

# Arrow keys
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-history
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-history
[[ -n "${terminfo[kcub1]}" ]] && bindkey "${terminfo[kcub1]}" backward-char
[[ -n "${terminfo[kcuf1]}" ]] && bindkey "${terminfo[kcuf1]}" forward-char

# Home / End
[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]}"  ]] && bindkey "${terminfo[kend]}"  end-of-line

# Delete: delete character under/after cursor
[[ -n "${terminfo[kdch1]}" ]] && bindkey "${terminfo[kdch1]}" delete-char

# Common Kitty/xterm fallback sequences
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char

# Ctrl + Home / Ctrl + End
bindkey '^[[1;5H' beginning-of-line
bindkey '^[[1;5F' end-of-line

# Ctrl + Left / Ctrl + Right
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word


# ---- Starship prompt --------------------------------------------------------

if [[ ${TERM:-} != "dumb" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi


# ---- Zoxide -----------------------------------------------------------------

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi


# ---- Shared configuration ---------------------------------------------------

export SHELL_SHARED_DIR="$HOME/.config/terminal/shared"

[[ -r "$SHELL_SHARED_DIR/theme.sh" ]] &&
  source "$SHELL_SHARED_DIR/theme.sh"

[[ -r "$SHELL_SHARED_DIR/aliases.sh" ]] &&
  source "$SHELL_SHARED_DIR/aliases.sh"

[[ -r "$SHELL_SHARED_DIR/functions.sh" ]] &&
  source "$SHELL_SHARED_DIR/functions.sh"


# ---- Zsh-specific aliases/functions ----------------------------------------

for _zsh_extra in \
  "$HOME"/.config/terminal/zsh/aliases.d/*(N) \
  "$HOME"/.config/terminal/zsh/functions.d/*(N)
do
  [[ -f "$_zsh_extra" ]] && source "$_zsh_extra"
done

unset _zsh_extra


# ---- SSH Agent --------------------------------------------------------------

export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"


# ---- Leenfetch --------------------------------------------------------------

if [[ -o interactive ]] && command -v leenfetch >/dev/null 2>&1; then
  leenfetch --ascii_distro arch_small
fi
