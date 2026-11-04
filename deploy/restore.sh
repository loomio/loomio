#!/usr/bin/env bash
# Restore into a prepared Docker Compose directory on a fresh server.
set -euo pipefail
umask 077
if [[ $# != 2 ]]; then
  echo "Usage: sudo bash restore.sh BACKUP.tar.gz DEPLOY_DIR" >&2
  exit 1
fi
archive=$(cd -- "$(dirname -- "$1")" && pwd -P)/$(basename -- "$1")
cd -- "$2"
test -f docker-compose.yml
[[ -z ${COMPOSE_FILE:-} && -z ${COMPOSE_PROJECT_NAME:-} ]] || {
  echo "Unset COMPOSE_FILE and COMPOSE_PROJECT_NAME first." >&2; exit 1;
}
for path in .env storage files engines plugins public pgdata database.dump; do
  [[ ! -e "$path" ]] || { echo "Refusing existing $path; restore on a fresh installation." >&2; exit 1; }
done
tar -xzf "$archive"
docker compose config --quiet
if [[ -n $(docker compose ps -aq) ]]; then
  echo "This Compose project already has containers; restore on a fresh server." >&2
  exit 1
fi
docker compose up -d db redis
ready=
for attempt in {1..60}; do
  if docker compose exec -T db pg_isready -h 127.0.0.1 -U postgres > /dev/null 2>&1; then ready=yes; break; fi
  sleep 2
done
[[ "$ready" == yes ]] || { echo "PostgreSQL did not become ready; inspect docker compose logs db." >&2; exit 1; }
if [[ $(docker compose exec -T db psql -U postgres -d postgres -Atc "SELECT 1 FROM pg_database WHERE datname = 'loomio_production'") != 1 ]]; then
  docker compose exec -T db createdb -U postgres loomio_production
fi
docker compose exec -T db pg_restore -U postgres --dbname=loomio_production --no-owner --no-privileges --exit-on-error < database.dump
docker compose exec -T db psql -U postgres -d loomio_production -c ANALYZE
echo "Restored. Start Loomio with: docker compose up -d"
