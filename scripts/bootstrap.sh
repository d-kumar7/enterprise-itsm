#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"
mkdir -p config api/uploads/{tickets,branding,ai}

if [ ! -f config/db.env ]; then
    DB_PASS=$(openssl rand -hex 16)
    ROOT_DB_PASS=$(openssl rand -hex 16)
    cat << ENV > config/db.env
MYSQL_ROOT_PASSWORD=${ROOT_DB_PASS}
MYSQL_DATABASE=itsm_prod
MYSQL_USER=itsm_user
MYSQL_PASSWORD=${DB_PASS}
MYSQL_HOST=itsm-db
MYSQL_PORT=3306
ENV
    chmod 600 config/db.env
fi

if [ ! -f config/app.env ]; then
    JWT_SEC=$(openssl rand -hex 32)
    API_KEY_SEC=$(openssl rand -hex 24)
    cat << ENV > config/app.env
APP_PORT=8000
JWT_SECRET=${JWT_SEC}
SHARED_API_KEY=${API_KEY_SEC}
REDIS_URL=redis://itsm-redis:6379/0
DB_POOL_SIZE=15
DB_MAX_OVERFLOW=30
DB_POOL_RECYCLE=3600
ENV
    chmod 600 config/app.env
fi

docker compose up -d --build --remove-orphans
docker image prune -f
