shellhelp() {
  printf '%s%s shellhelp%s  %savailable shell shortcuts%s\n\n' "$_SHELL_UI_BOLD" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET" "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"

  printf '%s%s Navigation%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET"
  printf '  %-14s %s\n' 'c, cls' 'Clear the terminal'
  printf '  %-14s %s\n' 'ls' 'List files with eza and icons'
  printf '  %-14s %s\n' 'l' 'Long file list'
  printf '  %-14s %s\n' 'll' 'Long all-files list'
  printf '  %-14s %s\n' 'ld' 'Long directory-only list'
  printf '  %-14s %s\n' 'lt' 'Tree view, depth 1'
  printf '  %-14s %s\n' 'lz' 'Fallback plain ls alias'
  printf '  %-14s %s\n' '.. / ... / .3' 'Go up directories quickly'
  printf '  %-14s %s\n' '.4 / .5' 'Go up 4 or 5 directories'
  printf '  %-14s %s\n\n' 'mkdir' 'Always create parent directories'

  printf '%s%s Editors and Files%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET"
  printf '  %-14s %s\n' 'vc' 'Open VS Code'
  printf '  %-14s %s\n' 'vim' 'Use Neovim'
  printf '  %-14s %s\n' 'cat' 'Use bat instead of cat'
  printf '  %-14s %s\n' 'open PATH' 'Open a file or URL with xdg-open'
  printf '  %-14s %s\n\n' 'opendir [PATH]' 'Open a directory in Nautilus'

  printf '%s%s Packages%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_PKG" "$_SHELL_UI_RESET"
  printf '  %sOrchestration%s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
  printf '    %-18s %s\n' 'update' 'Update repo packages and AUR packages'
  printf '\n'
  printf '  %sRepo Packages%s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
  printf '    %-18s %s\n' 'pkg update' 'Update repo packages with pacman'
  printf '    %-18s %s\n' 'pkg install PKG' 'Install package(s) with pacman'
  printf '    %-18s %s\n' 'pkg remove PKG' 'Remove package(s) with pacman'
  printf '    %-18s %s\n' 'pkg remove-deps' 'Remove package(s) and dependencies'
  printf '    %-18s %s\n' 'pkg search QUERY' 'Search pacman repositories'
  printf '    %-18s %s\n' 'pkg list' 'List installed packages'
  printf '    %-18s %s\n' 'pkg info PKG' 'Show installed package info'
  printf '    %-18s %s\n' 'pkg help' 'Show package command help'
  printf '\n'
  printf '  %sAUR Packages%s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
  printf '    %-18s %s\n' 'aur update' 'Update AUR packages with yay'
  printf '    %-18s %s\n' 'aur install PKG' 'Install AUR package(s) with yay'
  printf '    %-18s %s\n' 'aur remove PKG' 'Remove AUR package(s)'
  printf '    %-18s %s\n' 'aur remove-deps' 'Remove AUR package(s) with deps'
  printf '    %-18s %s\n' 'aur search QUERY' 'Search AUR packages'
  printf '    %-18s %s\n' 'aur list' 'List installed AUR packages'
  printf '    %-18s %s\n' 'aur info PKG' 'Show AUR package info'
  printf '    %-18s %s\n\n' 'aur help' 'Show AUR command help'

  printf '%s%s Containers%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET"
  printf '  %sDocker Engine%s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
  printf '    %-18s %s\n' 'docker' 'Run docker through sudo'
  printf '    %-18s %s\n' 'dockerstart' 'Start Docker service'
  printf '    %-18s %s\n' 'dockerstop' 'Stop Docker service and socket'
  printf '    %-18s %s\n' 'dockerlist' 'List running containers'
  printf '\n'
  printf '  %sService Pattern%s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
  printf '    %-18s %s\n' '<service> up' 'Create or start the service container'
  printf '    %-18s %s\n' '<service> down' 'Stop the service container'
  printf '    %-18s %s\n' '<service> status' 'Show runtime state and endpoint'
  printf '    %-18s %s\n' '<service> config' 'Show current effective config'
  printf '    %-18s %s\n' '<service> recreate' 'Recreate with new image/port/options'
  printf '    %-18s %s\n' '<service> help' 'Show service-specific help'
  printf '\n'
  printf '  %sAvailable Services%s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
  printf '    %-18s %s\n' 'postgres' 'PostgreSQL plus pgAdmin'
  printf '    %-18s %s\n' 'mongo' 'MongoDB'
  printf '    %-18s %s\n' 'redis' 'Redis'
  printf '    %-18s %s\n\n' 'searx' 'SearXNG'

  printf '%s%s Projects%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_BUILD" "$_SHELL_UI_RESET"
  printf '  %-14s %s\n' 'initmvn NAME' 'Create a Maven project skeleton'
  printf '  %-14s %s\n\n' 'initgo NAME' 'Create a Go project skeleton'

  printf '%s%s Network and Notify%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_NET" "$_SHELL_UI_RESET"
  printf '  %-14s %s\n' 'send-notif' 'Send a message to your ntfy topic'
  printf '  %-14s %s\n' 'iporigin ARG' 'Resolve and geo-look up IP/domain/URL'
  printf '  %-14s %s\n\n' 'ips' 'Show local and public IP addresses'

  printf '%s%s Help%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET"
  printf '  %-14s %s\n' 'shellhelp' 'Show this help page'
  printf '  %-14s %s\n' 'ntool help' 'Show ntool command help'
}
