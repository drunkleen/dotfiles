send-notif() {
  local ntfy_topic="${NTFY_TOPIC:-}"
  local ntfy_url="https://ntfy.sh/${ntfy_topic}"
  local ntfy_title="Archlinux - Hogwarts"
  local raw message

  command -v curl >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s curl\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }

  [[ -n "$ntfy_topic" ]] || {
    printf '%s%s Missing env var:%s NTFY_TOPIC\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }

  if (( $# == 0 )); then
    if [[ ! -t 0 ]]; then
      raw="$(cat)"
    else
      printf '%s%s Usage:%s send-notif <message>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
      return 1
    fi
  else
    raw="$*"
  fi

  raw=${raw//'%'/'%%'}
  printf -v message "%b" "$raw"

  if curl -fsS -o /dev/null \
    -H "Title: ${ntfy_title}" \
    --data-binary "$message" \
    "$ntfy_url"; then
    printf '%s%s Notification sent%s\n' "$_SHELL_UI_GREEN" "$_SHELL_ICON_NOTE" "$_SHELL_UI_RESET"
  else
    printf '%s%s Failed to send notification%s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  fi
}
