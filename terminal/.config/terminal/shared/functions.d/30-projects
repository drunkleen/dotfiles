initmvn() {
  local name="${1:-}"
  (( $# )) || {
    printf '%s%s Usage:%s initmvn <name>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }
  [[ ! -e "$name" ]] || {
    printf '%s%s Directory already exists:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$name" >&2
    return 1
  }
  command -v mvn >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s mvn\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }
  command -v curl >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s curl\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }

  printf '%s%s Initializing Maven project:%s %s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_BUILD" "$_SHELL_UI_RESET" "$name"
  mvn archetype:generate \
    -DgroupId="com.drunkleen.${name}" \
    -DartifactId="${name}" \
    -DarchetypeArtifactId=maven-archetype-quickstart \
    -DarchetypeVersion=1.5 \
    -DinteractiveMode=false

  touch "./${name}/.env"
  curl -fsSLo "./${name}/.gitignore" https://raw.githubusercontent.com/github/gitignore/refs/heads/main/Maven.gitignore
  printf '%s%s Maven project ready:%s %s\n' "$_SHELL_UI_GREEN" "$_SHELL_ICON_OK" "$_SHELL_UI_RESET" "$name"
}

initgo() {
  local name="${1:-}"
  (( $# )) || {
    printf '%s%s Usage:%s initgo <name>\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }
  [[ ! -e "$name" ]] || {
    printf '%s%s Directory already exists:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$name" >&2
    return 1
  }
  command -v go >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s go\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }
  command -v curl >/dev/null 2>&1 || {
    printf '%s%s Missing command:%s curl\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" >&2
    return 1
  }

  printf '%s%s Initializing Go project:%s %s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_BUILD" "$_SHELL_UI_RESET" "$name"
  mkdir -p "$name"
  pushd "$name" >/dev/null || return 1

  go mod init "github.com/drunkleen/${name}"
  : > main.go
  : > .env
  curl -fsSLo .gitignore https://raw.githubusercontent.com/github/gitignore/refs/heads/main/community/Golang/Go.AllowList.gitignore

  popd >/dev/null || return 1
  printf '%s%s Go project ready:%s %s\n' "$_SHELL_UI_GREEN" "$_SHELL_ICON_OK" "$_SHELL_UI_RESET" "$name"
}
