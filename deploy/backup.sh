#!/usr/bin/env bash
# Archive deployment files and a full PostgreSQL dump; keep file directories as files.
set -euo pipefail
umask 077
if [[ $# -gt 3 || ( $# == 3 && $3 != --leave-stopped ) ]]; then
  echo "Usage: bash backup.sh [DEPLOY_DIR [OUTPUT_DIR [--leave-stopped]]]" >&2
  exit 1
fi
deploy=$(cd -- "${1:-.}" && pwd -P)
mkdir -p -- "${2:-/root}"
output=$(cd -- "${2:-/root}" && pwd -P)
[[ "$output/" != "$deploy/"* ]] || { echo "Output must be outside the deployment directory." >&2; exit 1; }
cd -- "$deploy"
test -f .env && test -f docker-compose.yml && test -d storage
contents=(.env storage)
for path in files engines plugins public; do
  if [[ -d "$path" ]]; then contents+=("$path"); fi
done
[[ -z ${COMPOSE_FILE:-} ]] || { echo "Unset COMPOSE_FILE first." >&2; exit 1; }
exec 9> .handover-backup.lock
flock -n 9 || { echo "Another backup is running." >&2; exit 1; }
docker compose config --quiet
docker compose exec -T db pg_isready -h 127.0.0.1 -U postgres > /dev/null
stage=$(mktemp -d "$output/.loomio-backup.XXXXXXXX")
stopped=()
resume() {
  if ((${#stopped[@]})); then
    docker compose start "${stopped[@]}" || return 1
    stopped=()
  fi
}
cleanup() {
  status=$?
  trap - EXIT
  resume || status=1
  rm -rf -- "$stage"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
docker compose ps --services --status running > "$stage/running"
while IFS= read -r service; do
  case "$service" in app|worker|haraka|hocuspocus) stopped+=("$service");; esac
done < "$stage/running"
echo "Stopping application services while copying database and deployment files..." >&2
if ((${#stopped[@]})); then docker compose stop -t 120 "${stopped[@]}"; fi
docker compose exec -T db pg_dump -U postgres --format=custom --no-owner loomio_production > "$stage/database.dump"
docker compose exec -T db pg_restore --list < "$stage/database.dump" > /dev/null
cp -a -- "${contents[@]}" "$stage/"
if [[ ${3:-} != --leave-stopped ]]; then resume; fi
archive="loomio-$(hostname -s)-$(date -u +%Y%m%dT%H%M%SZ).tar.gz"
test ! -e "$output/$archive" && test ! -e "$output/$archive.sha256"
echo "Compressing ${contents[*]} and database.dump..." >&2
tar -C "$stage" -czf "$stage/archive.partial" "${contents[@]}" database.dump
mv -- "$stage/archive.partial" "$output/$archive"
(cd -- "$output" && sha256sum "$archive" > "$archive.sha256")
if [[ ${3:-} == --leave-stopped ]]; then
  stopped=()
  echo "Source application services remain stopped for cutover." >&2
fi
echo "Backup: $output/$archive"
echo "Checksum: $output/$archive.sha256"
