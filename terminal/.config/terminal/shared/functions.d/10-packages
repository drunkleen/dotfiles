update() {
  printf '%s%s %sUpdating packages and AUR%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_PKG" "$_SHELL_UI_BOLD" "$_SHELL_UI_RESET"
  pkg update "$@" || return 1

  if command -v yay >/dev/null 2>&1; then
    aur update "$@" || return 1
  else
    printf '%s%s Skipping AUR update:%s yay not installed\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET"
  fi
}

pkg() {
  local subcmd="${1:-}"
  shift || true

  case "$subcmd" in
    update)
      printf '%s%s %sUpdating repo packages%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_PKG" "$_SHELL_UI_BOLD" "$_SHELL_UI_RESET"
      sudo pacman -Syu "$@"
      ;;
    install)
      (( $# )) || {
        printf '%s%s Usage:%s pkg install <package...>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s Installing:%s %s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_PKG" "$_SHELL_UI_RESET" "$*"
      sudo pacman -S "$@"
      ;;
    remove)
      (( $# )) || {
        printf '%s%s Usage:%s pkg remove <package...>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s Removing:%s %s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_PKG" "$_SHELL_UI_RESET" "$*"
      sudo pacman -R "$@"
      ;;
    remove-deps)
      (( $# )) || {
        printf '%s%s Usage:%s pkg remove-deps <package...>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s Removing with deps:%s %s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_PKG" "$_SHELL_UI_RESET" "$*"
      sudo pacman -Rns "$@"
      ;;
    search)
      (( $# )) || {
        printf '%s%s Usage:%s pkg search <query>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s Searching repos:%s %s\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_PKG" "$_SHELL_UI_RESET" "$*"
      pacman -Ss "$@"
      ;;
    list)
      printf '%s%s Installed packages%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_PKG" "$_SHELL_UI_RESET"
      pacman -Q
      ;;
    info)
      (( $# )) || {
        printf '%s%s Usage:%s pkg info <package...>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s Package info:%s %s\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_PKG" "$_SHELL_UI_RESET" "$*"
      pacman -Qi "$@"
      ;;
    ''|help|-h|--help)
      printf '%s%s pkg%s  %ssystem package manager wrapper%s\n\n' "$_SHELL_UI_BOLD" "$_SHELL_ICON_PKG" "$_SHELL_UI_RESET" "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
      printf '  %-18s %s\n' 'pkg update' 'Update repo packages with pacman'
      printf '  %-18s %s\n' 'pkg install PKG' 'Install package(s) with pacman'
      printf '  %-18s %s\n' 'pkg remove PKG' 'Remove package(s) with pacman'
      printf '  %-18s %s\n' 'pkg remove-deps' 'Remove package(s) and dependencies'
      printf '  %-18s %s\n' 'pkg search QUERY' 'Search pacman repositories'
      printf '  %-18s %s\n' 'pkg list' 'List installed packages'
      printf '  %-18s %s\n' 'pkg info PKG' 'Show installed package info'
      printf '  %-18s %s\n' 'pkg help' 'Show this help page'
      ;;
    *)
      printf '%s%s Unknown pkg command:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$subcmd" >&2
      printf 'Try: pkg help\n' >&2
      return 1
      ;;
  esac
}

aur() {
  local subcmd="${1:-}"
  shift || true

  command -v yay >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s yay\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }

  case "$subcmd" in
    update)
      printf '%s%s %sUpdating AUR packages%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_AUR" "$_SHELL_UI_BOLD" "$_SHELL_UI_RESET"
      yay -Sua "$@"
      ;;
    install)
      (( $# )) || {
        printf '%s%s Usage:%s aur install <package...>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s Installing AUR:%s %s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_AUR" "$_SHELL_UI_RESET" "$*"
      yay -S "$@"
      ;;
    remove)
      (( $# )) || {
        printf '%s%s Usage:%s aur remove <package...>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s Removing AUR:%s %s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_AUR" "$_SHELL_UI_RESET" "$*"
      yay -R "$@"
      ;;
    remove-deps)
      (( $# )) || {
        printf '%s%s Usage:%s aur remove-deps <package...>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s Removing AUR with deps:%s %s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_AUR" "$_SHELL_UI_RESET" "$*"
      yay -Rns "$@"
      ;;
    search)
      (( $# )) || {
        printf '%s%s Usage:%s aur search <query>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s Searching AUR:%s %s\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_AUR" "$_SHELL_UI_RESET" "$*"
      yay -Ss "$@"
      ;;
    list)
      printf '%s%s Installed AUR packages%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_AUR" "$_SHELL_UI_RESET"
      yay -Qm
      ;;
    info)
      (( $# )) || {
        printf '%s%s Usage:%s aur info <package...>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
        return 1
      }
      printf '%s%s AUR package info:%s %s\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_AUR" "$_SHELL_UI_RESET" "$*"
      yay -Qi "$@"
      ;;
    ''|help|-h|--help)
      printf '%s%s aur%s  %sAUR package manager wrapper%s\n\n' "$_SHELL_UI_BOLD" "$_SHELL_ICON_AUR" "$_SHELL_UI_RESET" "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
      printf '  %-18s %s\n' 'aur update' 'Update AUR packages with yay'
      printf '  %-18s %s\n' 'aur install PKG' 'Install AUR package(s) with yay'
      printf '  %-18s %s\n' 'aur remove PKG' 'Remove AUR package(s)'
      printf '  %-18s %s\n' 'aur remove-deps' 'Remove AUR package(s) with deps'
      printf '  %-18s %s\n' 'aur search QUERY' 'Search AUR packages'
      printf '  %-18s %s\n' 'aur list' 'List installed AUR packages'
      printf '  %-18s %s\n' 'aur info PKG' 'Show AUR package info'
      printf '  %-18s %s\n' 'aur help' 'Show this help page'
      ;;
    *)
      printf '%s%s Unknown aur command:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$subcmd" >&2
      printf 'Try: aur help\n' >&2
      return 1
      ;;
  esac
}
