# Push relay deployment

Deploy this standalone Ruby service to the dedicated relay VPS. SQLite runs inside the relay process and stores its file in a private bind mount. No PostgreSQL container is needed. The application publishes no host ports; Kamal Proxy supplies HTTPS through the `kamal` Docker network and targets the relay on port 8080.

## Prepare

Install Docker and Docker Compose on the VPS. Create the proxy network and start the standard Kamal Proxy before deploying its route. Copy the relay source to `/opt/loomio-push-relay`, including dotfiles. Run the commands below from `deploy/`.

Create `.env` from `.env.example`. Generate the encryption key once with `openssl rand -base64 32`; keep it stable across deployments. Set the Apple team ID, app bundle ID, production key ID, and sandbox key ID. Protect `.env` with mode 0600. Store the keys in `secrets/apns-production.p8` and `secrets/apns-sandbox.p8`.

The relay container runs as UID/GID 1000. Create `storage/` and `secrets/` with mode 0700 and ownership 1000:1000; signing key files must be readable by that user, mode 0600. The SQLite directory is writable and the secrets directory is mounted read-only. Both are excluded from Git and the image context.

```sh
install -d -m 700 -o 1000 -g 1000 storage secrets
chmod 600 .env
chown 1000:1000 secrets/*.p8
chmod 600 secrets/*.p8
```

Inspect `docker network inspect kamal` and set `PROXY_TRUSTED_CIDR` to its actual subnet. Point the relay hostname's A record to the dedicated VPS. For Cloudflare protection, enable its proxy, use Full (strict) TLS, set `LOOMIO_TRUSTED_EDGE_CIDRS` to the current [Cloudflare IPv4 and IPv6 ranges](https://www.cloudflare.com/ips/), and restrict origin HTTP/HTTPS to those ranges. Keep SSH restricted to the deploy host. Let's Encrypt HTTP validation must remain reachable through Cloudflare on port 80. For DNS-only routing, omit the edge CIDRs. Replace `push.example.com` below with the chosen hostname.

## Start

```sh
docker compose build relay
docker compose run --rm --no-deps relay ruby bin/migrate
docker compose up -d --wait relay
docker compose ps
docker exec kamal-proxy kamal-proxy deploy loomio-push-relay --host=push.example.com --target=loomio-push-relay:8080 --tls --forward-headers --health-check-path=/health --buffer-requests --max-request-body=16384
curl --fail https://push.example.com/health
```

The proxy and application both cap request bodies at 16 KiB. The relay enforces registration and signed-route rate limits; see the [relay README](../README.md) for proxy trust, memory bounds, and the single-process deployment constraint. Keep the relay port private and leave `ALLOW_PRIVATE_HOSTS` unset.

Configure `PUSH_RELAY_URL=https://push.example.com` on participating Loomio hosts only after HTTPS, backups, and recovery are verified. Restart their web and notification workers using their normal deployment process. APNs keys stay on the relay.

## Verify

1. Connect the iOS app to a selected Loomio host and grant notification permission.
2. Verify registration and the app's native test notification. Debug installations use Sandbox; TestFlight uses Production.
3. Background the app, trigger a real notification, and confirm tapping it opens the host's notification page.
4. Repeat for each supported host. A host without relay configuration must not report push as registered.
5. Verify device revocation/disconnection stops delivery and removes the registration. Confirm invalid APNs tokens remove registrations, while APNs signing/configuration failures retain them for retry.

The health endpoint checks protocol availability only. A healthy container does not prove Apple has accepted its credentials.

## Backup and restore

Create a consistent snapshot with the same image and storage mount:

```sh
docker compose run --rm --no-deps relay ruby bin/backup /app/storage/backup.sqlite3
```

Back up `storage/backup.sqlite3`, `.env`, and `secrets/` together through the private encrypted off-host backup system. Schedule this command before each backup run. Provider disk backups are additional recovery coverage. Do not rely on copying a live SQLite file without its WAL or on provider backups alone for consistency.

Rehearse restoration in an empty, isolated storage directory. Stop the application before restoring the standalone backup as `storage/relay.sqlite3`; retain the prior storage directory, restore the matching encryption/signing keys, set directory mode 0700 and database mode 0600 owned by UID/GID 1000, run migrations, and start the relay. Never combine a restored database with old WAL sidecars. Losing the encryption key requires every device to register again.

## Updates and rollback

Before updating, create and verify a database backup. Rebuild the image, run migrations, and recreate the relay. Keep the prior image and compatible database backup for recovery. Restore into separate storage while the application is stopped; do not restore over the running service. This Ruby/SQLite stack replaces the unreleased Node/PostgreSQL prototype and requires a fresh SQLite database on its first deployment.

To stop new mobile deliveries, remove `PUSH_RELAY_URL` from participating Loomio hosts and restart their web and notification workers. Other notification channels continue using their existing configuration.
