# ---- Enhanced fzf integration (portable across bash and zsh) ----

FZF_PREVIEW="$HOME/.config/terminal/shared/fzf-preview.sh"

# --- Default opts: shared across all fzf invocations ---
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

export FZF_DEFAULT_OPTS="
  --height 40% --min-height 15 --border --layout=reverse --info=inline
  --preview-window='right:60%:wrap'
  --color='fg:#d4d4d4,fg+:#ffffff,bg+:#3a3d41,hl+:#6cb2eb'
  --bind='ctrl-y:execute-silent(echo -n {} | xclip -selection clipboard)+abort'
  --bind='ctrl-r:reload(fd --type f --hidden --follow --exclude .git)'
  --bind='alt-down:preview-down,alt-up:preview-up'
"

export FZF_CTRL_T_OPTS="--preview '$FZF_PREVIEW {}' --header 'Files — Ctrl-Y to copy path'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=hidden --header 'History' --bind 'ctrl-r:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'eza -la --icons {}' --header 'Directories'"

# --- Open a file with the editor via fzf (preview-aware) ---
fp() {
  local file
  file=$(fzf --preview "$FZF_PREVIEW {}" --header 'Pick a file to edit') || return
  "$EDITOR" "$file"
}

# --- cd with fzf (bonus; ALT-C also works) ---
fc() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git | fzf --preview 'eza -la --icons {}' --header 'cd') || return
  cd "$dir" || return
}

# --- Kill a process by fuzzy name ---
fkill() {
  local pid
  pid=$(ps -eo pid,comm,args --sort=-%cpu | fzf --header 'Kill process' --preview 'echo {}' --preview-window=hidden |
    awk '{print $1}') || return
  kill -9 "$pid" 2>/dev/null && echo "killed $pid"
}

# --- Fuzzy git log -> checkout ---
fglog() {
  local commit
  commit=$(git log --oneline --graph --color=always | fzf --ansi --reverse --header 'Git log (Enter = checkout)' --preview 'echo {}' --preview-window=hidden |
    sed -E 's/^[^a-f0-9]*([a-f0-9]{7,}).*/\1/') || return
  [[ -n $commit ]] && git checkout "$commit"
}