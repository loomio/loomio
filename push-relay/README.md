# Loomio Push Relay

The relay maps pseudonymous Loomio mobile registrations to APNs device tokens. It receives no Loomio user identity, browser cookie, access token, refresh token, discussion content, poll content, or notification text.

## Run

Requires Node 24+, PostgreSQL, and an Apple APNs token-signing key.

```sh
npm install
export DATABASE_URL=postgres://localhost/loomio_push_relay
export RELAY_ENCRYPTION_KEY="$(openssl rand -base64 32)"
export APNS_TEAM_ID=YOUR_TEAM_ID
export APNS_KEY_ID=YOUR_KEY_ID
export APNS_PRIVATE_KEY='<contents of your APNs .p8 key>'
export APNS_TOPIC=YOUR_APP_BUNDLE_ID
npm run migrate
npm start
```

Set `APNS_TEAM_ID` and `APNS_TOPIC` to your app's Apple Developer Team ID and bundle ID.

New Apple signing keys are environment-specific. The `APNS_KEY_ID` and `APNS_PRIVATE_KEY` settings above select the production key. Configure `APNS_SANDBOX_KEY_ID` and `APNS_SANDBOX_PRIVATE_KEY` for Xcode Debug installations. Without a sandbox override, the relay uses the base key for both environments, supporting older Apple keys that permit both. Set both sandbox values together; incomplete configuration fails at startup.

Signing keys may instead be mounted as read-only files, with their paths supplied in `APNS_PRIVATE_KEY_FILE` and `APNS_SANDBOX_PRIVATE_KEY_FILE`. Do not supply both an inline key and its file setting. The [deployment stack](deploy/README.md) includes private database storage, mounted signing keys, and integration with the existing TLS proxy.

Keep `ALLOW_PRIVATE_HOSTS` unset in a public deployment. A private relay may define it only when its network policy separately limits reachable destinations. Like Loomio's other boolean environment flags, its presence enables the setting regardless of its value.

The application limits registrations to 30 requests per minute per client IP and signed registration routes to 300 requests per minute per client IP, with bursts of 10 and 50 additional requests respectively. Events and deletions share the signed-route budget, including failed authentication attempts. Limits run before body parsing, database access, or outbound calls. Excess requests receive HTTP 429 with a `Retry-After` header; health checks are exempt.

Rate-limit counters live in memory, reset on restart, and are independent for each relay process. The limiter tracks at most 10,000 client/route pairs and sweeps entries idle for at least a minute once per minute while handling requests. If the table fills, new pairs receive HTTP 429 until space becomes available; active limits are retained. Deploy a single relay process, or add a shared limiter when scaling to multiple instances.

Expose the service through a TLS reverse proxy. By default the relay uses the socket's client IP and ignores forwarded headers. When running behind a proxy, set `PROXY_TRUSTED_CIDR` to its internal IPv4 or IPv6 network, for example `172.18.0.0/16`. The relay walks `X-Forwarded-For` from the nearest proxy towards the client, stopping at the first address outside that network. The proxy must append the actual connecting address or overwrite the header. Restrict direct access to the application port and keep the trusted network limited to your proxies. Cloudflare can provide additional traffic protection, but is not required for the application limits.

APNs tokens and delivery keys are encrypted with AES-256-GCM. Their encryption key, the APNs `.p8` key, and database credentials must come from the deployment secret store and must never be committed.

Run `npm run migrate` as a release step before starting a new relay version. Configure the reverse proxy health check to call `GET /health`; it returns the relay protocol version without touching PostgreSQL or APNs.
