#!/usr/bin/env bash
# LabProject - WSL2 Ubuntu setup (Docker CLI, Bench dependencies, systemd)
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
LAB_ROOT="/mnt/c/LabProject"
BENCH_HOME="$LAB_ROOT/backend/frappe-bench"

log() { echo -e "\n==> $*"; }

log "Updating Ubuntu packages"
sudo apt-get update -y
sudo apt-get upgrade -y

log "Installing base dependencies for Frappe Bench"
sudo apt-get install -y \
  git python3-dev python3-pip python3-venv \
  redis-server mariadb-client libmariadb-dev \
  curl wget gnupg2 software-properties-common \
  xvfb libfontconfig libmysqlclient-dev \
  build-essential cron sudo \
  nginx supervisor

log "Configuring MariaDB client (for bench)"
if ! grep -q "labproject" /etc/mysql/my.cnf 2>/dev/null; then
  echo "[client]
default-character-set = utf8mb4" | sudo tee -a /etc/mysql/my.cnf >/dev/null 2>&1 || true
fi

log "Installing Node via nvm (Frappe compatible)"
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install 18
nvm use 18
npm install -g yarn

log "Installing frappe-bench"
if ! command -v bench &>/dev/null; then
  pip3 install frappe-bench --break-system-packages 2>/dev/null || pip3 install frappe-bench
fi

log "Docker inside WSL (use Docker Desktop WSL integration)"
if ! command -v docker &>/dev/null; then
  log "Docker CLI not found - enable Docker Desktop WSL integration for Ubuntu"
else
  docker --version
  docker compose version
fi

log "Enable systemd in WSL (Ubuntu 24.04)"
if ! grep -q "systemd=true" /etc/wsl.conf 2>/dev/null; then
  echo -e "[boot]\nsystemd=true" | sudo tee /etc/wsl.conf
  echo "systemd enabled - restart WSL from PowerShell: wsl --shutdown"
fi

log "Starting Docker data services from Windows path"
cd "$LAB_ROOT/docker"
docker compose up -d db redis-cache redis-queue 2>/dev/null || docker-compose up -d db redis-cache redis-queue

log "Initializing Frappe bench (if not exists)"
mkdir -p "$LAB_ROOT/backend"
if [ ! -d "$BENCH_HOME" ]; then
  cd "$LAB_ROOT/backend"
  bench init frappe-bench --frappe-branch version-15 --python python3 --skip-redis-config-generation
  cd "$BENCH_HOME"
  bench set-config -g redis_cache "redis://127.0.0.1:6379"
  bench set-config -g redis_queue "redis://127.0.0.1:6380"
  bench set-config -g redis_socketio "redis://127.0.0.1:6380"
fi

log "Linking lab_core app"
mkdir -p "$BENCH_HOME/apps"
if [ ! -L "$BENCH_HOME/apps/lab_core" ] && [ ! -d "$BENCH_HOME/apps/lab_core" ]; then
  ln -sf "$LAB_ROOT/apps/lab_core" "$BENCH_HOME/apps/lab_core"
fi

log "Waiting for MariaDB (Docker)..."
for i in $(seq 1 30); do
  if mysqladmin ping -h 127.0.0.1 -P 3307 -u root -padmin --silent 2>/dev/null; then
    break
  fi
  sleep 2
done

cd "$BENCH_HOME"

log "Creating site lab.localhost (if missing)"
if [ ! -d "$BENCH_HOME/sites/lab.localhost" ]; then
  bench new-site lab.localhost \
    --mariadb-root-password admin \
    --admin-password admin \
    --db-host 127.0.0.1 \
    --db-port 3307 \
    --no-mariadb-socket
fi

if ! bench --site lab.localhost list-apps 2>/dev/null | grep -q lab_core; then
  bench --site lab.localhost install-app lab_core
fi

bench --site lab.localhost set-config developer_mode 1
bench --site lab.localhost set-config allow_cors "*"
bench --site lab.localhost set-config ignore_csrf 1
bench --site lab.localhost migrate

log "WSL setup complete"
echo "Bench path: $BENCH_HOME"
echo "Start Frappe: cd $BENCH_HOME && bench start"
