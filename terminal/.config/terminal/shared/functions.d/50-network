iporigin() {
  local input target host ip info

  (( $# )) || {
    printf '%s%s Usage:%s iporigin <ip|domain|url>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }
  command -v curl >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s curl\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }
  command -v jq >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s jq\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }
  command -v getent >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s getent\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }

  input="$1"
  target="$input"

  if [[ "$input" =~ ^[a-zA-Z][a-zA-Z0-9+.-]*:// ]]; then
    target="${input#*://}"
    target="${target%%/*}"
  fi

  target="${target#*@}"

  if [[ "$target" =~ ^\[.*\](:[0-9]+)?$ ]]; then
    host="${target#[}"
    host="${host%%]*}"
  else
    host="${target%%:*}"
  fi

  if [[ "$host" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || [[ "$host" == *:* ]]; then
    ip="$host"
  else
    ip="$(getent ahosts "$host" | awk '{print $1}' | head -n 1)"
    [[ -n "$ip" ]] || {
      printf '%s%s Could not resolve host:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$host" >&2
      return 1
    }
  fi

  info="$(curl -fsS "http://ip-api.com/json/${ip}")"
  printf '%s%s IP origin lookup%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_NET" "$_SHELL_UI_RESET"
  printf '  %sInput%s    %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$input"
  printf '  %sHost%s     %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$host"
  printf '  %sIP%s       %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$ip"
  printf '  %sCountry%s  %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$(echo "$info" | jq -r '.country')"
  printf '  %sRegion%s   %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$(echo "$info" | jq -r '.regionName')"
  printf '  %sCity%s     %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$(echo "$info" | jq -r '.city')"
  printf '  %sISP%s      %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$(echo "$info" | jq -r '.isp')"
  printf '  %sASN%s      %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$(echo "$info" | jq -r '.as')"
}

ips() {
  local hide_re='^(br-|veth|virbr|podman|tun|tap)'
  local pub4 pub6

  command -v ip >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s ip\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }
  command -v curl >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s curl\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }

  printf '%s%s Local IPv4%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_NET" "$_SHELL_UI_RESET"
  ip -o -4 addr show up \
    | awk -v re="$hide_re" '$2 !~ re { print $2, $4 }' \
    | sort -k1,1

  echo
  printf '%s%s Local IPv6%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_NET" "$_SHELL_UI_RESET"
  ip -o -6 addr show up scope global 2>/dev/null \
    | awk -v re="$hide_re" '$2 !~ re { print $2, $4 }' \
    | sort -k1,1

  pub4="$(curl -4fsS --max-time 3 https://ifconfig.co 2>/dev/null || true)"
  pub6="$(curl -6fsS --max-time 3 https://ifconfig.co 2>/dev/null || true)"

  echo
  printf '  %sPublic IPv4%s  %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "${pub4:-not available}"
  printf '  %sPublic IPv6%s  %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "${pub6:-not available}"
}
