# Loomio Push Relay Protocol v1

## Privacy boundary

The relay stores a pseudonymous registration ID, normalized Loomio host origin, APNs environment, encrypted APNs token, and encrypted per-device delivery key. It does not receive a Loomio user ID, email address, password, web session, host API token, discussion title, actor name, poll content, notification URL, or rendered notification text.

Recent activity and unread state are fetched directly from the Loomio host. The relay is not an activity proxy or identity provider.

## Registration

The app obtains a 60-second one-use authorization from `POST /api/v1/mobile/relay-authorizations` using its Loomio mobile bearer token, then sends it with its APNs token to `POST /v1/registrations` on the configured relay.

The relay validates the HTTPS origin, blocks private/reserved destinations, pins the validated DNS result for TLS connection, follows no redirects, and redeems the authorization at `POST /api/v1/mobile/relay-authorizations/verify`. A self-hosted relay may explicitly allow private origins under its own network policy.

The public relay ingress limits registration attempts to 30 requests per minute per client IP. Authenticated registration routes are limited to 300 requests per minute per source host. These limits are enforced by a TLS reverse proxy whose application port is not directly reachable; forwarded client addresses are accepted only from that proxy.

The host returns only a random registration UUID and a random per-device delivery key. The authorization is consumed atomically. Registration is idempotent by registration UUID, and a rotated APNs token replaces the previous APNs identity.

## Authenticated delivery

Host requests to `/v1/registrations/:id`, `/v1/registrations/:id/events` carry:

- `X-Loomio-Timestamp`: current Unix seconds, accepted within five minutes.
- `X-Loomio-Nonce`: a fresh base64url random value.
- `X-Loomio-Signature`: base64url HMAC-SHA256 over `METHOD`, path, timestamp, nonce, and the hexadecimal SHA-256 body digest, separated by newlines.

Nonces are retained for ten minutes and accepted once. Notification `event_id` values are idempotent per registration. Failed or abandoned events can be reclaimed for retry; delivered events cannot.

## APNs payload

The relay constructs the APNs body. Hosts cannot provide alert text or arbitrary data.

```json
{
  "aps": {
    "alert": {
      "title": "New Loomio activity",
      "body": "Open Loomio to view it."
    },
    "sound": "default",
    "badge": 3
  },
  "registration_id": "pseudonymous-uuid",
  "event_id": "idempotency-uuid"
}
```

Production and sandbox APNs endpoints are selected from the stored registration environment. APNs invalid-token responses delete the relay registration and return `410` to the host. Transient APNs failures return `503` with `Retry-After` so Loomio's job retry policy remains authoritative.

## Lifecycle

- `DELETE /v1/registrations/:id` removes APNs and delivery-key material.
- Loomio device revocation queues deletion and stops producing new native deliveries immediately.
- Relay event/nonce metadata is bounded and cleaned periodically; raw request bodies and credentials are never logged.
