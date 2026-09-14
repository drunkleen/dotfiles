dockerstart() {
  printf '%s%s Starting Docker%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET"
  sudo systemctl start docker
}

dockerstop() {
  printf '%s%s Stopping Docker%s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET"
  sudo systemctl stop docker.socket
  sudo systemctl stop docker.service
}

dockerlist() {
  printf '%s%s Running containers%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET"
  sudo docker container ls
}

postgres() {
  local subcmd="${1:-}"
  shift || true

  local pg_container="${PG_CONTAINER_NAME:-postgresql}"
  local pg_image="${PG_CONTAINER_IMAGE:-postgres:16-alpine}"
  local pg_user="${PG_USER:-pguser}"
  local pg_password="${PG_PASSWORD:-pgpass}"
  local pg_db="${PG_DATABASE:-postgres}"
  local pg_port="${PG_PORT:-5432}"
  local pgadmin_container="${PGADMIN_CONTAINER_NAME:-pgAdmin}"
  local pgadmin_image="${PGADMIN_CONTAINER_IMAGE:-dpage/pgadmin4:latest}"
  local pgadmin_email="${PGADMIN_DEFAULT_EMAIL:-admin@example.com}"
  local pgadmin_password="${PGADMIN_DEFAULT_PASSWORD:-admin}"
  local pgadmin_port="${PGADMIN_PORT:-8081}"
  local current_pgadmin_email ip pgadmin_ip pg_state pgadmin_state ready_url ready_wait

  case "$subcmd" in
    recreate)
      while (( $# )); do
        case "$1" in
          --user) pg_user="${2:-}"; shift 2 ;;
          --password) pg_password="${2:-}"; shift 2 ;;
          --db) pg_db="${2:-}"; shift 2 ;;
          --port) pg_port="${2:-}"; shift 2 ;;
          --image) pg_image="${2:-}"; shift 2 ;;
          --container-name) pg_container="${2:-}"; shift 2 ;;
          --pgadmin-email) pgadmin_email="${2:-}"; shift 2 ;;
          --pgadmin-password) pgadmin_password="${2:-}"; shift 2 ;;
          --pgadmin-port) pgadmin_port="${2:-}"; shift 2 ;;
          --pgadmin-image) pgadmin_image="${2:-}"; shift 2 ;;
          --pgadmin-name) pgadmin_container="${2:-}"; shift 2 ;;
          *)
            printf '%s%s Unknown postgres recreate option:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$1" >&2
            return 1
            ;;
        esac
      done

      printf '%s%s Recreating PostgreSQL stack%s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      sudo docker container inspect "$pg_container" >/dev/null 2>&1 && sudo docker rm -f "$pg_container" >/dev/null
      sudo docker container inspect "$pgadmin_container" >/dev/null 2>&1 && sudo docker rm -f "$pgadmin_container" >/dev/null

      PG_CONTAINER_NAME="$pg_container" \
      PG_CONTAINER_IMAGE="$pg_image" \
      PG_USER="$pg_user" \
      PG_PASSWORD="$pg_password" \
      PG_DATABASE="$pg_db" \
      PG_PORT="$pg_port" \
      PGADMIN_CONTAINER_NAME="$pgadmin_container" \
      PGADMIN_CONTAINER_IMAGE="$pgadmin_image" \
      PGADMIN_DEFAULT_EMAIL="$pgadmin_email" \
      PGADMIN_DEFAULT_PASSWORD="$pgadmin_password" \
      PGADMIN_PORT="$pgadmin_port" \
      postgres up
      ;;
    up)
      printf '%s%s Starting PostgreSQL stack%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"

      if ! sudo docker container inspect "$pg_container" >/dev/null 2>&1; then
        printf '%s%s Creating container:%s %s\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET" "$pg_container"
        sudo docker run -d \
          --name "$pg_container" \
          -e POSTGRES_USER="$pg_user" \
          -e POSTGRES_PASSWORD="$pg_password" \
          -e POSTGRES_DB="$pg_db" \
          -p "${pg_port}:5432" \
          "$pg_image" >/dev/null || return 1
      else
        sudo docker start "$pg_container" >/dev/null || return 1
      fi

      if sudo docker container inspect "$pgadmin_container" >/dev/null 2>&1; then
        current_pgadmin_email="$(
          sudo docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$pgadmin_container" 2>/dev/null \
            | awk -F= '$1=="PGADMIN_DEFAULT_EMAIL" {print $2; exit}'
        )"

        if [[ -n "$current_pgadmin_email" && "$current_pgadmin_email" != "$pgadmin_email" ]]; then
          printf '%s%s Recreating container:%s %s (email changed)\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET" "$pgadmin_container"
          sudo docker rm -f "$pgadmin_container" >/dev/null || return 1
        fi
      fi

      if ! sudo docker container inspect "$pgadmin_container" >/dev/null 2>&1; then
        printf '%s%s Creating container:%s %s\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET" "$pgadmin_container"
        sudo docker run -d \
          --name "$pgadmin_container" \
          -e PGADMIN_DEFAULT_EMAIL="$pgadmin_email" \
          -e PGADMIN_DEFAULT_PASSWORD="$pgadmin_password" \
          -p "${pgadmin_port}:80" \
          "$pgadmin_image" >/dev/null || return 1
      else
        sudo docker start "$pgadmin_container" >/dev/null || return 1
      fi

      ip="$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$pg_container" 2>/dev/null)"
      pgadmin_ip="$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$pgadmin_container" 2>/dev/null)"
      ready_url="http://127.0.0.1:${pgadmin_port}/login"
      ready_wait=0

      if command -v curl >/dev/null 2>&1; then
        until curl -fsSI --max-time 2 "$ready_url" >/dev/null 2>&1; do
          ready_wait=$((ready_wait + 1))
          if (( ready_wait >= 15 )); then
            printf '%s%s pgAdmin not ready yet:%s %s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET" "$ready_url"
            break
          fi
          sleep 1
        done
      fi

      printf '%s%s PostgreSQL:%s postgres://%s:%s@127.0.0.1:%s/%s\n' "$_SHELL_UI_GREEN" "$_SHELL_ICON_OK" "$_SHELL_UI_RESET" "$pg_user" "$pg_password" "$pg_port" "$pg_db"
      [[ -n "$ip" ]] && printf '  %scontainer ip%s  %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$ip"
      printf '%s%s pgAdmin:%s http://127.0.0.1:%s\n' "$_SHELL_UI_GREEN" "$_SHELL_ICON_OK" "$_SHELL_UI_RESET" "$pgadmin_port"
      [[ -n "$pgadmin_ip" ]] && printf '  %scontainer ip%s  %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$pgadmin_ip"
      ;;
    down)
      printf '%s%s Stopping PostgreSQL stack%s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      sudo docker container inspect "$pg_container" >/dev/null 2>&1 && sudo docker stop "$pg_container" >/dev/null
      sudo docker container inspect "$pgadmin_container" >/dev/null 2>&1 && sudo docker stop "$pgadmin_container" >/dev/null
      ;;
    status)
      printf '%s%s PostgreSQL stack%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      if sudo docker container inspect "$pg_container" >/dev/null 2>&1; then
        pg_state="$(sudo docker inspect -f '{{.State.Status}}' "$pg_container" 2>/dev/null)"
        printf '  %-12s %s\n' 'postgres' "$pg_state"
        printf '  %-12s %s\n' 'endpoint' "postgres://$pg_user:$pg_password@127.0.0.1:$pg_port/$pg_db"
      else
        printf '  %-12s %s\n' 'postgres' 'missing'
      fi

      if sudo docker container inspect "$pgadmin_container" >/dev/null 2>&1; then
        pgadmin_state="$(sudo docker inspect -f '{{.State.Status}}' "$pgadmin_container" 2>/dev/null)"
        printf '  %-12s %s\n' 'pgadmin' "$pgadmin_state"
        printf '  %-12s %s\n' 'ui' "http://127.0.0.1:$pgadmin_port"
      else
        printf '  %-12s %s\n' 'pgadmin' 'missing'
      fi
      ;;
    config)
      printf '%s%s PostgreSQL config%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      printf '  %-16s %s\n' 'container' "$pg_container"
      printf '  %-16s %s\n' 'image' "$pg_image"
      printf '  %-16s %s\n' 'user' "$pg_user"
      printf '  %-16s %s\n' 'password' "$pg_password"
      printf '  %-16s %s\n' 'database' "$pg_db"
      printf '  %-16s %s\n' 'port' "$pg_port"
      printf '  %-16s %s\n' 'pgadmin name' "$pgadmin_container"
      printf '  %-16s %s\n' 'pgadmin image' "$pgadmin_image"
      printf '  %-16s %s\n' 'pgadmin email' "$pgadmin_email"
      printf '  %-16s %s\n' 'pgadmin password' "$pgadmin_password"
      printf '  %-16s %s\n' 'pgadmin port' "$pgadmin_port"
      ;;
    ''|help|-h|--help)
      printf '%s%s postgres%s  %sPostgreSQL and pgAdmin stack%s\n\n' "$_SHELL_UI_BOLD" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET" "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
      printf '  %-18s %s\n' 'postgres up' 'Create/start PostgreSQL and pgAdmin'
      printf '  %-18s %s\n' 'postgres down' 'Stop PostgreSQL and pgAdmin'
      printf '  %-18s %s\n' 'postgres status' 'Show PostgreSQL and pgAdmin state'
      printf '  %-18s %s\n' 'postgres config' 'Show PostgreSQL and pgAdmin config'
      printf '  %-18s %s\n' 'postgres recreate' 'Recreate stack with new options'
      printf '  %-18s %s\n' '  --user USER' 'Set PostgreSQL username'
      printf '  %-18s %s\n' '  --password PASS' 'Set PostgreSQL password'
      printf '  %-18s %s\n' '  --db NAME' 'Set PostgreSQL database'
      printf '  %-18s %s\n' '  --port PORT' 'Set PostgreSQL host port'
      printf '  %-18s %s\n' '  --pgadmin-email' 'Set pgAdmin login email'
      printf '  %-18s %s\n' '  --pgadmin-password' 'Set pgAdmin login password'
      printf '  %-18s %s\n' '  --pgadmin-port' 'Set pgAdmin host port'
      printf '  %-18s %s\n' 'postgres help' 'Show this help page'
      ;;
    *)
      printf '%s%s Unknown postgres command:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$subcmd" >&2
      printf 'Try: postgres help\n' >&2
      return 1
      ;;
  esac
}

mongo() {
  local subcmd="${1:-}"
  shift || true

  local mongo_container="${MONGO_CONTAINER_NAME:-mongodb}"
  local mongo_image="${MONGO_CONTAINER_IMAGE:-mongo:7}"
  local mongo_port="${MONGO_PORT:-27017}"
  local mongo_state

  case "$subcmd" in
    recreate)
      while (( $# )); do
        case "$1" in
          --port) mongo_port="${2:-}"; shift 2 ;;
          --image) mongo_image="${2:-}"; shift 2 ;;
          --name) mongo_container="${2:-}"; shift 2 ;;
          *)
            printf '%s%s Unknown mongo recreate option:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$1" >&2
            return 1
            ;;
        esac
      done

      printf '%s%s Recreating MongoDB%s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      sudo docker container inspect "$mongo_container" >/dev/null 2>&1 && sudo docker rm -f "$mongo_container" >/dev/null
      MONGO_CONTAINER_NAME="$mongo_container" MONGO_CONTAINER_IMAGE="$mongo_image" MONGO_PORT="$mongo_port" mongo up
      ;;
    up)
      printf '%s%s Starting MongoDB%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      if ! sudo docker container inspect "$mongo_container" >/dev/null 2>&1; then
        printf '%s%s Creating container:%s %s\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET" "$mongo_container"
        sudo docker run -d \
          --name "$mongo_container" \
          -p "${mongo_port}:27017" \
          "$mongo_image" >/dev/null || return 1
      else
        sudo docker start "$mongo_container" >/dev/null || return 1
      fi
      printf '%s%s MongoDB:%s mongodb://127.0.0.1:%s\n' "$_SHELL_UI_GREEN" "$_SHELL_ICON_OK" "$_SHELL_UI_RESET" "$mongo_port"
      ;;
    down)
      printf '%s%s Stopping MongoDB%s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      sudo docker container inspect "$mongo_container" >/dev/null 2>&1 && sudo docker stop "$mongo_container" >/dev/null
      ;;
    status)
      printf '%s%s MongoDB%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      if sudo docker container inspect "$mongo_container" >/dev/null 2>&1; then
        mongo_state="$(sudo docker inspect -f '{{.State.Status}}' "$mongo_container" 2>/dev/null)"
        printf '  %-12s %s\n' 'container' "$mongo_state"
        printf '  %-12s %s\n' 'endpoint' "mongodb://127.0.0.1:$mongo_port"
      else
        printf '  %-12s %s\n' 'container' 'missing'
      fi
      ;;
    config)
      printf '%s%s MongoDB config%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      printf '  %-12s %s\n' 'container' "$mongo_container"
      printf '  %-12s %s\n' 'image' "$mongo_image"
      printf '  %-12s %s\n' 'port' "$mongo_port"
      ;;
    ''|help|-h|--help)
      printf '%s%s mongo%s  %sMongoDB container wrapper%s\n\n' "$_SHELL_UI_BOLD" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET" "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
      printf '  %-18s %s\n' 'mongo up' 'Create/start MongoDB'
      printf '  %-18s %s\n' 'mongo down' 'Stop MongoDB'
      printf '  %-18s %s\n' 'mongo status' 'Show MongoDB state'
      printf '  %-18s %s\n' 'mongo config' 'Show MongoDB config'
      printf '  %-18s %s\n' 'mongo recreate' 'Recreate MongoDB with new options'
      printf '  %-18s %s\n' '  --port PORT' 'Set MongoDB host port'
      printf '  %-18s %s\n' '  --image IMAGE' 'Set MongoDB image'
      printf '  %-18s %s\n' '  --name NAME' 'Set MongoDB container name'
      printf '  %-18s %s\n' 'mongo help' 'Show this help page'
      ;;
    *)
      printf '%s%s Unknown mongo command:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$subcmd" >&2
      printf 'Try: mongo help\n' >&2
      return 1
      ;;
  esac
}

redis() {
  local subcmd="${1:-}"
  shift || true

  local redis_container="${REDIS_CONTAINER_NAME:-redis}"
  local redis_image="${REDIS_CONTAINER_IMAGE:-redis:7-alpine}"
  local redis_port="${REDIS_PORT:-6379}"
  local redis_state ip

  case "$subcmd" in
    recreate)
      while (( $# )); do
        case "$1" in
          --port) redis_port="${2:-}"; shift 2 ;;
          --image) redis_image="${2:-}"; shift 2 ;;
          --name) redis_container="${2:-}"; shift 2 ;;
          *)
            printf '%s%s Unknown redis recreate option:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$1" >&2
            return 1
            ;;
        esac
      done

      printf '%s%s Recreating Redis%s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      sudo docker container inspect "$redis_container" >/dev/null 2>&1 && sudo docker rm -f "$redis_container" >/dev/null
      REDIS_CONTAINER_NAME="$redis_container" REDIS_CONTAINER_IMAGE="$redis_image" REDIS_PORT="$redis_port" redis up
      ;;
    up)
      printf '%s%s Starting Redis%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      if ! sudo docker container inspect "$redis_container" >/dev/null 2>&1; then
        printf '%s%s Creating container:%s %s\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET" "$redis_container"
        sudo docker run -d \
          --name "$redis_container" \
          -p "${redis_port}:6379" \
          "$redis_image" >/dev/null || return 1
      else
        sudo docker start "$redis_container" >/dev/null || return 1
      fi

      ip="$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$redis_container" 2>/dev/null)"
      printf '%s%s Redis:%s redis://127.0.0.1:%s\n' "$_SHELL_UI_GREEN" "$_SHELL_ICON_OK" "$_SHELL_UI_RESET" "$redis_port"
      [[ -n "$ip" ]] && printf '  %scontainer ip%s  %s\n' "$_SHELL_UI_DIM" "$_SHELL_UI_RESET" "$ip"
      ;;
    down)
      printf '%s%s Stopping Redis%s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      sudo docker container inspect "$redis_container" >/dev/null 2>&1 && sudo docker stop "$redis_container" >/dev/null
      ;;
    status)
      printf '%s%s Redis%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      if sudo docker container inspect "$redis_container" >/dev/null 2>&1; then
        redis_state="$(sudo docker inspect -f '{{.State.Status}}' "$redis_container" 2>/dev/null)"
        printf '  %-12s %s\n' 'container' "$redis_state"
        printf '  %-12s %s\n' 'endpoint' "redis://127.0.0.1:$redis_port"
      else
        printf '  %-12s %s\n' 'container' 'missing'
      fi
      ;;
    config)
      printf '%s%s Redis config%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET"
      printf '  %-12s %s\n' 'container' "$redis_container"
      printf '  %-12s %s\n' 'image' "$redis_image"
      printf '  %-12s %s\n' 'port' "$redis_port"
      ;;
    ''|help|-h|--help)
      printf '%s%s redis%s  %sRedis container wrapper%s\n\n' "$_SHELL_UI_BOLD" "$_SHELL_ICON_DB" "$_SHELL_UI_RESET" "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
      printf '  %-18s %s\n' 'redis up' 'Create/start Redis'
      printf '  %-18s %s\n' 'redis down' 'Stop Redis'
      printf '  %-18s %s\n' 'redis status' 'Show Redis state'
      printf '  %-18s %s\n' 'redis config' 'Show Redis config'
      printf '  %-18s %s\n' 'redis recreate' 'Recreate Redis with new options'
      printf '  %-18s %s\n' '  --port PORT' 'Set Redis host port'
      printf '  %-18s %s\n' '  --image IMAGE' 'Set Redis image'
      printf '  %-18s %s\n' '  --name NAME' 'Set Redis container name'
      printf '  %-18s %s\n' 'redis help' 'Show this help page'
      ;;
    *)
      printf '%s%s Unknown redis command:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$subcmd" >&2
      printf 'Try: redis help\n' >&2
      return 1
      ;;
  esac
}

searx() {
  local subcmd="${1:-}"
  shift || true

  local searx_container="${SEARX_CONTAINER_NAME:-searx}"
  local searx_image="${SEARX_CONTAINER_IMAGE:-searxng/searxng:latest}"
  local searx_port="${SEARX_PORT:-8080}"
  local searx_state

  case "$subcmd" in
    recreate)
      while (( $# )); do
        case "$1" in
          --port) searx_port="${2:-}"; shift 2 ;;
          --image) searx_image="${2:-}"; shift 2 ;;
          --name) searx_container="${2:-}"; shift 2 ;;
          *)
            printf '%s%s Unknown searx recreate option:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$1" >&2
            return 1
            ;;
        esac
      done

      printf '%s%s Recreating SearXNG%s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET"
      sudo docker container inspect "$searx_container" >/dev/null 2>&1 && sudo docker rm -f "$searx_container" >/dev/null
      SEARX_CONTAINER_NAME="$searx_container" SEARX_CONTAINER_IMAGE="$searx_image" SEARX_PORT="$searx_port" searx up
      ;;
    up)
      printf '%s%s Starting SearX%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET"
      if ! sudo docker container inspect "$searx_container" >/dev/null 2>&1; then
        printf '%s%s Creating container:%s %s\n' "$_SHELL_UI_CYAN" "$_SHELL_ICON_INFO" "$_SHELL_UI_RESET" "$searx_container"
        sudo docker run -d \
          --name "$searx_container" \
          -p "${searx_port}:8080" \
          "$searx_image" >/dev/null || return 1
      else
        sudo docker start "$searx_container" >/dev/null || return 1
      fi
      printf '%s%s SearX:%s http://127.0.0.1:%s\n' "$_SHELL_UI_GREEN" "$_SHELL_ICON_OK" "$_SHELL_UI_RESET" "$searx_port"
      ;;
    down)
      printf '%s%s Stopping SearX%s\n' "$_SHELL_UI_YELLOW" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET"
      sudo docker container inspect "$searx_container" >/dev/null 2>&1 && sudo docker stop "$searx_container" >/dev/null
      ;;
    status)
      printf '%s%s SearX%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET"
      if sudo docker container inspect "$searx_container" >/dev/null 2>&1; then
        searx_state="$(sudo docker inspect -f '{{.State.Status}}' "$searx_container" 2>/dev/null)"
        printf '  %-12s %s\n' 'container' "$searx_state"
        printf '  %-12s %s\n' 'endpoint' "http://127.0.0.1:$searx_port"
      else
        printf '  %-12s %s\n' 'container' 'missing'
      fi
      ;;
    config)
      printf '%s%s SearXNG config%s\n' "$_SHELL_UI_BLUE" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET"
      printf '  %-12s %s\n' 'container' "$searx_container"
      printf '  %-12s %s\n' 'image' "$searx_image"
      printf '  %-12s %s\n' 'port' "$searx_port"
      ;;
    ''|help|-h|--help)
      printf '%s%s searx%s  %sSearXNG container wrapper%s\n\n' "$_SHELL_UI_BOLD" "$_SHELL_ICON_DOCKER" "$_SHELL_UI_RESET" "$_SHELL_UI_DIM" "$_SHELL_UI_RESET"
      printf '  %-18s %s\n' 'searx up' 'Create/start SearXNG'
      printf '  %-18s %s\n' 'searx down' 'Stop SearXNG'
      printf '  %-18s %s\n' 'searx status' 'Show SearXNG state'
      printf '  %-18s %s\n' 'searx config' 'Show SearXNG config'
      printf '  %-18s %s\n' 'searx recreate' 'Recreate SearXNG with new options'
      printf '  %-18s %s\n' '  --port PORT' 'Set SearXNG host port'
      printf '  %-18s %s\n' '  --image IMAGE' 'Set SearXNG image'
      printf '  %-18s %s\n' '  --name NAME' 'Set SearXNG container name'
      printf '  %-18s %s\n' 'searx help' 'Show this help page'
      ;;
    *)
      printf '%s%s Unknown searx command:%s %s\n' "$_SHELL_UI_RED" "$_SHELL_ICON_ERR" "$_SHELL_UI_RESET" "$subcmd" >&2
      printf 'Try: searx help\n' >&2
      return 1
      ;;
  esac
}
