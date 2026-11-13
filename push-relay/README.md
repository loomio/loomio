# Loomio Push Relay

A standalone Ruby Rack service that maps pseudonymous Loomio mobile registrations to APNs device tokens. It receives no Loomio user identity, browser cookie, access token, refresh token, discussion content, poll content, or notification text. Puma serves the API, SQLite stores encrypted registrations and delivery metadata, and HTTPX sends HTTP/2 requests to Apple. Rails and Node are not required to run the relay.

## Run

Requires Ruby 3.4+ and an Apple APNs token-signing key. The container uses Ruby 4.0.9.

```sh
bundle install
mkdir -m 700 storage
export LOOMIO_DATABASE_PATH="$PWD/storage/relay.sqlite3"
export RELAY_ENCRYPTION_KEY="$(openssl rand -base64 32)"
export APNS_TEAM_ID=YOUR_TEAM_ID
export APNS_KEY_ID=YOUR_PRODUCTION_KEY_ID
export APNS_PRIVATE_KEY_FILE=/private/path/apns-production.p8
export APNS_TOPIC=org.loomio.mobile
bundle exec ruby bin/migrate
bundle exec puma -C config/puma.rb config.ru
```

Generate the encryption key once and keep it in the private deployment secret store. Existing ciphertext depends on this key; do not regenerate it for a restart or deploy.

Set `APNS_TEAM_ID` and `APNS_TOPIC` to the app's Apple Developer Team ID and bundle ID. Configure `APNS_SANDBOX_KEY_ID` and `APNS_SANDBOX_PRIVATE_KEY_FILE` with a separate sandbox key for Xcode Debug installations. Without a sandbox override, the relay uses the production key for both environments, supporting older Apple keys that permit both. Incomplete sandbox configuration fails at startup. TestFlight uses production APNs.

Keys may instead be supplied as PEM strings in `APNS_PRIVATE_KEY` and `APNS_SANDBOX_PRIVATE_KEY`. Do not supply both an inline key and its file setting. The relay requires private P-256 EC keys and reads mounted keys at startup. The [deployment stack](deploy/README.md) supplies persistent SQLite storage and read-only key mounts.

Keep `ALLOW_PRIVATE_HOSTS` unset in a public deployment. A private relay may define it only when its network policy separately limits reachable destinations. Its presence enables the setting regardless of its value.

## Storage and delivery

Run `bundle exec ruby bin/migrate` before starting a new release. Migrations are tracked and applied transactionally. The first Ruby release uses a fresh SQLite database; PostgreSQL database files and SQL dumps from the unreleased Node prototype are not SQLite input.

SQLite uses WAL mode, foreign keys, a five-second lock timeout, and full synchronous commits. Registration replacement is atomic. Event and nonce claims use unique constraints, so simultaneous requests cannot claim the same delivery or replay the same nonce. No database transaction stays open during a network call. Failed deliveries can be retried immediately; processing events can be reclaimed after two minutes; delivered events remain deduplicated for their 30-day retention. The relay cleans expired nonce and event metadata hourly. Loomio's background workers own the retry schedule.

Run a single Puma process with four threads, as configured in `config/puma.rb`. Database operations are synchronized within the process. Rate-limit counters are also synchronized, live in memory, and reset on restart. Multiple relay processes would need a shared rate limiter.

APNs tokens and per-device delivery keys are encrypted with AES-256-GCM. The SQLite directory must be private because WAL and shared-memory sidecar files are created beside the database. The service creates database files with mode 0600; deployment instructions set the storage directory to 0700.

## HTTP limits and host verification

Registration attempts are limited to 30 requests per minute per client IP, with 10 additional burst requests. Signed event and deletion routes share a 300-per-minute budget, with 50 additional burst requests, including failed authentication attempts. Limits run before body parsing, database access, and outbound calls. Excess requests return HTTP 429 with `Retry-After`; health checks are exempt. Request bodies and host verification responses are limited to 16 KiB.

The limiter retains at most 10,000 client/route pairs and sweeps idle entries once per minute while handling requests. At capacity it rejects new pairs until space is available without evicting active limits.

Expose the service through a TLS proxy and keep the relay port private. By default, forwarded headers are ignored. Set `PROXY_TRUSTED_CIDR` to the proxy's internal network, for example `172.18.0.0/16`. The relay walks `X-Forwarded-For` from the nearest proxy towards the client, stopping at the first untrusted address. The proxy must append the actual connecting address or overwrite the header. For a Cloudflare-proxied deployment, set `LOOMIO_TRUSTED_EDGE_CIDRS` to Cloudflare's published IPv4 and IPv6 ranges, separated by whitespace or commas. The limiter accepts `CF-Connecting-IP` only when the nearest external hop, verified through the trusted local proxy chain, is in those ranges. Client-supplied copies of that header are ignored for other peers. Restrict origin HTTP/HTTPS to Cloudflare's ranges and keep those ranges current using [Cloudflare's address list](https://www.cloudflare.com/ips/).

Host verification accepts HTTPS origins only, rejects private/reserved DNS answers, pins the validated destination address while retaining hostname-based certificate verification, disables environment proxies, and follows no redirects.

`GET /health` returns protocol status without checking SQLite or APNs. Verify actual registration and device delivery before enabling a Loomio host.

## Backup and restore

Create a consistent standalone SQLite backup while the relay is running:

```sh
bundle exec ruby bin/backup /private/backups/relay.sqlite3
```

The command uses SQLite's online backup API, includes committed WAL pages, checks database integrity, and atomically replaces the destination with a mode-0600 backup. Back up that file together with the encryption key and APNs signing keys through encrypted off-host storage. Copying only the live database file while WAL is active is insufficient.

For recovery, stop the relay, retain the current storage directory for rollback, and place the restored standalone database in an empty private storage directory at `LOOMIO_DATABASE_PATH`. Restore the matching encryption key and signing keys, fix ownership for the container's UID 1000, then run migrations and start the relay. Test recovery in isolated storage before enabling host delivery. Do not overwrite a live database or mix restored files with old WAL sidecars.

## Tests

```sh
bundle install
bundle exec rake test
```

The Minitest suite uses temporary real SQLite databases, Rack protocol checks, captured APNs requests, and host-verification transport fixtures. It covers registration and replacement, transaction rollback, concurrent claims, signatures/replays, retry and cleanup, environment-specific APNs signing, proxy trust, rate limits, and encrypted backup restoration. It needs neither Rails nor PostgreSQL and sends no real device notifications.
