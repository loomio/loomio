# Request history and local log limits

Loomio keeps session and activity records in its database. The additional incident trail is web request metadata retained on the host across proxy and application deployments. Sentry continues reporting exceptions; this setup does not enable Sentry log forwarding or archive routine application output.

| Setting | Private hosts | loomio.com web host |
| --- | --- | --- |
| Access-history retention | Up to 30 days | Up to 30 days |
| Rotate access files | Daily or over 32 MiB | Daily or over 128 MiB |
| Archived access files | 30, compressed | 30, compressed |
| Nominal access-history budget | About 1 GiB | About 4 GiB |
| Ordinary container logs | 20 MB × 3 files per container | 20 MB × 3 files per container |

A timer checks access-file rotation every five minutes. The oldest archives expire sooner when size-based rotation consumes the file count. The budget is a rotation target rather than a filesystem quota: active files can exceed the size threshold between checks, particularly during a request flood. Daily rotation and file-level expiry also give age limits a day of granularity. Monitor disk space and actual retained history after rollout. The worker-only loomio.com server needs the ordinary Docker limits but does not collect web access logs.

## What is retained

The proxy forwards its output to a dedicated local rsyslog socket. The host accepts only JSON entries containing a request method and an HTTP response status. It writes a fixed set of fields to `/var/log/loomio-access/access.jsonl`: received time, host, method, path, status, socket peer address, proxy-reported client address when present, request ID and browser user agent. Non-request proxy messages stay available in Docker's small local cache but are excluded from the archive.

The archive omits query strings, request/response bodies, cookies and extra headers. Sign-in, invitation and read-tracking token paths are replaced with placeholders. JSON escaping prevents embedded control characters from creating extra records. IP addresses and paths remain sensitive data: the archive directory is mode 0700 and files are mode 0600, owned by the host's syslog user. Only host operators should access them. A proxy-reported client address is not independently verified; use the actual peer and the deployed trusted-proxy configuration when interpreting it.

Archive files live on the host and survive container recreation. They remain local operational records, not an off-host or tamper-proof audit archive. There is no delivery guarantee during a logging-service failure or an exhausted socket queue. Docker's bounded cache can help investigate gaps; it is not an automatic replay queue. Check rsyslog health and rotation failures after rollout.

## Install host access logging

Ubuntu's standard rsyslog configuration must load `imuxsock`, and rsyslog must already be running. Install `rsyslog` and `logrotate` if they are not present. Copy `configure_logging.py` to the host, preview the exact changes, then apply them before starting a proxy configured to use its socket:

```sh
sudo python3 configure_logging.py --profile private
sudo python3 configure_logging.py --profile private --apply
```

Use `--profile production` on the loomio.com web host. No journal settings, Docker daemon defaults or application environment variables are changed. The installer saves previous managed files under `/var/lib/loomio/logging/`, configures the dedicated rsyslog socket and filtered output, validates rsyslog and logrotate, restarts rsyslog and enables the five-minute rotation timer. It does not recreate containers. Re-running it leaves unchanged configuration files alone. To stage files without running host commands:

```sh
python3 configure_logging.py --profile private --root /tmp/loomio-access-policy --apply
```

The rotation configuration uses a dedicated state file and sits outside `/etc/logrotate.d`, so the system's daily logrotate job does not independently rotate the same file. Rotation renames the file and signals rsyslog to reopen it; it does not use `copytruncate`.

## Private-host defaults and migration

The bundled Compose defaults set every ordinary container to Docker's `json-file` driver with `max-size: "20m"` and `max-file: "3"`. The Nginx proxy instead uses the dedicated local syslog socket and a bounded Docker cache. Its JSON access-log format uses the path without query parameters and includes the backend's response request ID.

On existing customized deployments, copy the `x-logging` mapping, each service's `logging` reference and the proxy's logging/environment settings from the bundled Compose file while preserving all unrelated service settings. Include local database, Redis, mail, certificate and backup containers when present. Check the installed nginx-proxy template supports `LOG_FORMAT` and `LOG_FORMAT_ESCAPE`; validate the generated Nginx configuration and a harmless request before rollout. Do not replace a customized Compose file wholesale.

```sh
docker compose config --quiet
```

Avoid printing resolved Compose configuration because it can contain secrets. Existing file logs are not migrated automatically. Preserve any evidence needed from the Argot incident before recreating its proxy. Driver and size-limit changes require container recreation; a restart alone is insufficient. Recreate supporting services deliberately because proxy, database and Redis recreation can interrupt service. Do not run the full update script merely to apply logging changes: it also prunes containers, pulls images and runs migrations.

## loomio.com

Merge `kamal-logging.yml` into the current authoritative Kamal configuration on the deploy host, preserving existing proxy ports, image/version, run options and Redis settings. The overlay sets ordinary web/job and Redis output to 20 MB × 3 files. Only the proxy forwards to the dedicated access-log socket. Remove conflicting role-level logging options and replace Redis's older `log-opt` value rather than appending duplicates.

Kamal 2.12 supports `proxy.run`. Setting `proxy.run.log_max_size: null` prevents its default `max-size=10m` option from being passed to the syslog driver; cache options provide the proxy's local fallback instead. The proxy and Redis need explicit logging options because they do not inherit the application-role logging mapping.

Validate effective run arguments using the installed Kamal version without printing resolved secrets. Apply web/job settings through normal deployment. Proxy and Redis recreation are separate operational steps; an app deployment does not migrate them automatically. Do not replace the current authoritative configuration with an older local copy.

## Verification and retrieval

```sh
systemctl status rsyslog loomio-access-log-rotation.timer --no-pager
sudo rsyslogd -N1
sudo logrotate --debug /etc/loomio/access-logrotate.conf
docker inspect loomio-app --format '{{json .HostConfig.LogConfig}}'
docker compose logs --since 1h nginx-proxy
sudo tail /var/log/loomio-access/access.jsonl
sudo du -sh /var/log/loomio-access
```

For a pilot, issue harmless successful and rejected requests with distinctive query values, then verify status/method/path/request-ID fields arrive and those query values do not. Also verify credential-bearing paths are masked. A disposable proxy-format test must remain readable in the host archive after its container is removed. Force rotation only on an isolated test file, then verify archived readback and subsequent output. Check host disk space, rsyslog errors, rotation timer status and oldest archive timestamps after 24 hours and seven days.

To inspect compressed archives, use `zcat` or `zgrep` against the numbered `.gz` files. Keep incident exports in a root-readable directory with an explicit deletion date. Review backup rules before including the access-log directory, since long-lived backups could extend retention beyond this policy.

## Session history

Logout marks the existing session row with `revoked_at` and immediately removes its push subscriptions. The row keeps its original user ID, IP address, browser information and creation time; there is no separate archive table. Every authentication lookup excludes revoked sessions, including HTTP requests, Action Cable, collaborative editing and the job administration engine. Push registration/reconciliation also rejects revoked sessions.

`LOOMIO_SESSION_RETENTION_DAYS` defaults to `60`. The hourly task deletes rows revoked at least that many days ago, in batches of 1,000, independently of optional orphan cleanup. Setting it to `0` purges revoked rows on the next hourly run. Active sessions are never expired by this setting, and repeated revocation preserves the original logout time. Permanent account deletion/redaction removes active and revoked sessions immediately.

Deploy this change with no overlap between old and new authentication readers: older code does not check `revoked_at`. For a rollback, first stop the new application processes, then purge all revoked session rows before starting older code. The migration's rollback performs that purge in batches before removing the column. Retained logout history is lost during that rollback, while active sessions are preserved.

## Rollback

Restore the former Compose/Kamal logging mappings and recreate only the intended containers. Keep the host archive for its remaining retention period. Stop and disable `loomio-access-log-rotation.timer` only when deliberately suspending expiry. Restore the installer's previous managed files, remove files listed in its `previously-absent.txt`, reload systemd and restart rsyslog. Restore the timer's prior enabled/running state when it existed before installation. Already expired files cannot be recovered by restoring configuration.

## References

- [Docker syslog driver](https://docs.docker.com/engine/logging/drivers/syslog/)
- [Docker file log rotation](https://docs.docker.com/engine/logging/drivers/json-file/)
- [rsyslog Unix socket inputs](https://docs.rsyslog.com/doc/configuration/modules/imuxsock.html)
- [Kamal proxy run options](https://kamal-deploy.org/docs/configuration/proxy/)
