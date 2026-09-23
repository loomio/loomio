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
export APNS_TOPIC=org.loomio.mobile
npm run migrate
npm start
```

Keep `ALLOW_PRIVATE_HOSTS` unset in a public deployment. A private relay may define it only when its network policy separately limits reachable destinations. Like Loomio's other boolean environment flags, its presence enables the setting regardless of its value.

Expose the service through a TLS reverse proxy that limits `POST /v1/registrations` to 30 requests per minute per client IP and all signed registration routes to 300 requests per minute per source host. Do not trust forwarded client-address headers unless the proxy overwrites them. Restrict direct access to the application port so these limits cannot be bypassed.

APNs tokens and delivery keys are encrypted with AES-256-GCM. Their encryption key, the APNs `.p8` key, and database credentials must come from the deployment secret store and must never be committed.

Run `npm run migrate` as a release step before starting a new relay version. Configure the reverse proxy health check to call `GET /health`; it returns the relay protocol version without touching PostgreSQL or APNs.
