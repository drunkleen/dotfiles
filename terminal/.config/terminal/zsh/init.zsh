# ---- Zsh options ----
setopt AUTO_CD                 # cd to a dir just by typing its path
setopt AUTO_PUSHD              # cd pushes to dir stack
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_HISTORY        # record timestamp in history
setopt HIST_IGNORE_ALL_DUPS    # drop older duplicates
setopt HIST_IGNORE_SPACE       # don't record lines starting with space
setopt HIST_FIND_NO_DUPS       # don't show dupes in history search
setopt INC_APPEND_HISTORY      # write history as commands run
setopt SHARE_HISTORY           # share history across sessions
setopt NO_BEEP
setopt PROMPT_SUBST
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

HISTFILE="$HOME/.zsh_history"
HISTSIZE=32768
SAVEHIST=32768

# ---- Omarchy environment (PATH + editors), shell-agnostic ----
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# ---- Rust toolchain ----
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# ---- Completion system ----
fpath=("$HOME/.config/terminal/zsh/completions" "$HOME/.config/terminal/bash/completions" $fpath)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
autoload -Uz compinit
compinit

# ---- starship prompt ----
if [[ ${TERM:-} != "dumb" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ---- zoxide ----
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ---- fzf: tab completion + CTRL-T / CTRL-R / ALT-C ----
if command -v fzf >/dev/null 2>&1; then
  source /usr/share/fzf/completion.zsh
  source /usr/share/fzf/key-bindings.zsh
fi

# ---- zsh plugins ----
# Note: zsh-autocomplete is intentionally NOT loaded — its real-time type-ahead
# menu conflicts with fzf-tab (both own the TAB key / completion pipeline).
# fzf-tab provides plain-TAB->fzf; zsh-autosuggestions provides inline suggestions.

# zsh-autosuggestions: fish-like inline suggestions
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
  && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf-tab: replace the completion selection menu with fzf (plain TAB -> fzf)
[[ -f /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]] \
  && source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# zsh-syntax-highlighting LAST (hooks into the ZLE line editor)
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] \
  && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Accept autosuggestion with the right arrow
bindkey '^[[C' forward-char

# ---- Shared config (theme + aliases + functions), portable across shells ----
export SHELL_SHARED_DIR="$HOME/.config/terminal/shared"
source "$SHELL_SHARED_DIR/theme.sh"
source "$SHELL_SHARED_DIR/aliases.sh"
source "$SHELL_SHARED_DIR/functions.sh"

# ---- Zsh-specific aliases/functions ----
for _zsh_extra in "$HOME"/.config/terminal/zsh/aliases.d/*(N) "$HOME"/.config/terminal/zsh/functions.d/*(N); do
  [[ -f "$_zsh_extra" ]] && source "$_zsh_extra"
done
unset _zsh_extra

export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# leenfetch
leenfetch --ascii_distro arch_small
