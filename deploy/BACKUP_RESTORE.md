# Backup and restore

The backup is a `.tar.gz` containing:

```text
.env
database.dump
storage/
files/       (if present)
engines/     (if present)
plugins/     (if present)
public/      (if present)
```

Directories are stored as ordinary files with their paths and permissions preserved. Redis, Docker volumes, TLS certificates, raw PostgreSQL data, old backups, and legacy `uploads/` are omitted.

## Backup

Keep `backup.sh` and `restore.sh` in `/root/loomio-deploy`.

```sh
cd /root/loomio-deploy
docker compose stop app worker haraka hocuspocus
bash ./backup.sh
docker compose up -d
```

This writes `/root/loomio-HOST-YYYYMMDDTHHMMSSZ.tar.gz` and its `.sha256` file; the timestamp is UTC.

## Restore

Follow [deploy/README.md](https://github.com/loomio/loomio/blob/master/deploy/README.md) through installing Docker and downloading the deployment files for the same Loomio version. Put `restore.sh` in `/root/loomio-deploy` and the backup files in `/root/`, then restore the latest backup:

```sh
cd /root
archive=$(ls -t loomio-*.tar.gz | head -n 1)
sha256sum -c "$archive.sha256"
bash /root/loomio-deploy/restore.sh "$archive" /root/loomio-deploy
cd /root/loomio-deploy
docker compose up -d
```
