open() {
  command -v xdg-open >/dev/null 2>&1 || {
    echo "Missing command: xdg-open" >&2
    return 1
  }
  xdg-open "$@" >/dev/null 2>&1 &
}

opendir() {
  if command -v nautilus >/dev/null 2>&1; then
    nautilus "${1:-.}" >/dev/null 2>&1 &
  else
    open "${1:-.}"
  fi
}
