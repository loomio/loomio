# Loomio Mobile Authentication Protocol v1

## Purpose

Authenticate a user through an Apple system browser session, create a revocable credential for native mobile APIs, and establish the user's ordinary Loomio session inside the isolated `WKWebView` without copying browser cookies or handling the user's password in native code.

This protocol is implemented by every compatible Loomio host. The push relay is not an identity provider and receives none of the credentials defined here.

## Actors and trust boundaries

- **Mobile app:** a public client. It cannot safely hold a client secret.
- **System browser authentication session:** `ASWebAuthenticationSession`, used for Cloudflare challenges, passwords, passkeys, and SSO.
- **Loomio host:** authenticates the user, issues and revokes device credentials, creates web sessions, and remains the source of truth for authorization.
- **Loomio WebView:** uses only Loomio's normal Secure, HttpOnly web-session cookie.
- **Push relay:** later receives a separate, narrowly scoped registration assertion. It never receives a Loomio access token, refresh token, web-session ticket, cookie, or password.

The app treats a selected host as untrusted input. All discovered endpoints must use HTTPS and exactly match the selected host's origin.

## Protocol constants

| Item | Value |
| --- | --- |
| Protocol version | `1` |
| Client type | Public native client |
| Provisional client ID | `org.loomio.mobile.ios` |
| Provisional callback | `org.loomio.mobile:/oauth/callback` |
| PKCE method | `S256` only |
| Authorization-code lifetime | 2 minutes |
| Web-session-ticket lifetime | 60 seconds |
| Access-token lifetime | 15 minutes |
| Refresh-token idle lifetime | 90 days |
| Refresh-token absolute lifetime | 1 year |

The client ID and callback become release constants when the production bundle identifier is selected. A callback received for any other path is rejected.

## Website-to-app connection link

The installed app registers `loomio` as a custom URL scheme. A Loomio website can offer a button or QR code containing:

```text
loomio://connect?config=https%3A%2F%2Fcommunity.example.org%2Fapi%2Fv1%2Fmobile%2Fconfig
```

The link is an unauthenticated connection proposal only. It must never contain a username, password, authorization code, access or refresh token, web-session ticket, cookie, relay credential, or confidential Loomio content.

On receipt, the app must:

1. Parse with `URLComponents` and require the exact scheme `loomio`, authority `connect`, no path, no fragment, and exactly one `config` parameter.
2. Bound the complete incoming URL and decoded parameter lengths before further processing.
3. Require the config URL to use HTTPS, contain no user information, query, or fragment, and have the exact path `/api/v1/mobile/config`.
4. Display the normalized host origin and ask the user to confirm “Connect to this Loomio host.” Do not fetch configuration or begin authentication before confirmation.
5. Fetch the configuration without following redirects, then apply all host-discovery validation below. Every advertised endpoint must match the config URL's origin.
6. Start the system-browser authorization sequence only after configuration succeeds and the user explicitly continues.

Any website or installed app can attempt to invoke a custom URL scheme, and another app can register the same scheme. Therefore, possession or successful opening of this link proves nothing about the sender or host. Security comes from HTTPS validation, explicit user confirmation, same-origin configuration, and the later PKCE-protected authorization flow.

Connection links are idempotent. Reopening the same link focuses the pending attempt rather than creating parallel authorization attempts. If a different host is already connected, clearly present the proposed replacement and preserve the existing connection until the new host authenticates successfully; then perform complete cleanup of the old host.

The website should retain an ordinary HTTPS/App Store fallback for devices without the app. Universal links may later supplement this flow for Loomio-controlled domains, but they cannot replace the custom connection scheme for arbitrary private hosts.

## Host discovery

The app requests the versioned Loomio API endpoint:

```http
GET /api/v1/mobile/config HTTP/1.1
Accept: application/json
```

Successful response:

```json
{
  "protocol_version": 1,
  "issuer": "https://community.example.org",
  "authorization_endpoint": "https://community.example.org/mobile/authorize",
  "token_endpoint": "https://community.example.org/api/v1/mobile/token",
  "web_session_ticket_endpoint": "https://community.example.org/api/v1/mobile/web-session-tickets",
  "web_session_bootstrap_endpoint": "https://community.example.org/mobile/web-session",
  "device_endpoint": "https://community.example.org/api/v1/mobile/device"
}
```

Requirements:

- Return `Content-Type: application/json` and `Cache-Control: no-store`.
- Every URL must be absolute HTTPS and match the selected origin, including its effective port.
- The app rejects redirects, unknown protocol versions, missing fields, user information in URLs, fragments, and endpoints on other origins.
- A missing or invalid document produces a clear “This Loomio host does not support the mobile app” state.

## Authorization sequence

### 1. Create a pending attempt

The app creates and retains until completion:

- `state`: 32 random bytes, base64url encoded.
- `code_verifier`: 32 random bytes, base64url encoded.
- `code_challenge`: base64url-encoded SHA-256 digest of `code_verifier`.
- Expected host origin, client ID, callback, and creation time.

Do not persist an incomplete attempt longer than ten minutes. Starting a new attempt cancels and deletes the previous attempt.

### 2. Open system authentication

The app starts a non-ephemeral `ASWebAuthenticationSession` so an existing browser login, Keychain credentials, and Cloudflare clearance may be reused. It opens:

```http
GET /mobile/authorize?
    response_type=code&
    client_id=org.loomio.mobile.ios&
    redirect_uri=org.loomio.mobile%3A%2Foauth%2Fcallback&
    code_challenge=<challenge>&
    code_challenge_method=S256&
    state=<state>
```

The host must:

1. Validate the client ID, exact redirect URI, parameter sizes, and `S256` method before login.
2. Run its normal browser login, Cloudflare, MFA, passkey, and SSO flows.
3. Display a confirmation naming the account, host, device category, and requested mobile access.
4. On approval, create a random authorization code and store only its digest with the user, redirect URI, PKCE challenge, expiry, and unused status.
5. Redirect to the exact registered callback.

Success callback:

```text
org.loomio.mobile:/oauth/callback?code=<opaque-code>&state=<state>
```

Cancellation and denial return no credential. OAuth-style error parameters may be returned, but must not contain sensitive details.

### 3. Validate the callback

Before exchanging anything, the app verifies:

- Scheme, path, and absence of unexpected authority/user information.
- Exact constant-time match with the pending `state`.
- Presence and bounded size of one `code` value.
- The attempt has not expired or already completed.

The callback cannot select or replace the host. The app exchanges the code only with the origin stored in the pending attempt.

### 4. Exchange the code

```http
POST /api/v1/mobile/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Accept: application/json

grant_type=authorization_code&
client_id=org.loomio.mobile.ios&
redirect_uri=org.loomio.mobile%3A%2Foauth%2Fcallback&
code=<opaque-code>&
code_verifier=<verifier>&
device_name=Rob%27s+iPhone
```

The server atomically consumes the authorization code and verifies its digest, expiry, client, redirect URI, and PKCE verifier. A code can succeed exactly once, including under concurrent requests.

Successful response:

```json
{
  "token_type": "Bearer",
  "access_token": "lm_at_<opaque-random-value>",
  "expires_in": 900,
  "refresh_token": "lm_rt_<opaque-random-value>",
  "refresh_token_expires_in": 7776000,
  "device": {
    "id": "4ecb8ee5-e61d-4ab5-91fe-9167f515488e",
    "name": "Rob's iPhone"
  },
  "scope": "activity:read activity:write notifications:manage relay:register web_session:create device:revoke"
}
```

Return `Cache-Control: no-store` and `Pragma: no-cache`. Tokens are opaque random values; do not put user or host data in them.

### 5. Create a WebView bootstrap ticket

The app authenticates with the access token:

```http
POST /api/v1/mobile/web-session-tickets HTTP/1.1
Authorization: Bearer lm_at_<opaque-random-value>
Content-Type: application/json
Accept: application/json

{}
```

Response:

```json
{
  "ticket": "lm_ws_<opaque-random-value>",
  "expires_in": 60
}
```

Only the digest is stored server-side. Issuing a new ticket invalidates any older unused ticket for that device.

### 6. Establish the ordinary Loomio web session

The app loads this request as the first top-level navigation in its host-specific `WKWebView`:

```http
POST /mobile/web-session HTTP/1.1
Content-Type: application/x-www-form-urlencoded

ticket=lm_ws_<opaque-random-value>
```

The host atomically consumes the ticket, verifies that its user and device remain active, rotates the Rails session identifier, sets the normal Secure and HttpOnly Loomio session cookie, and responds with `303 See Other` to a safe same-origin landing page.

The response must include `Cache-Control: no-store` and `Referrer-Policy: no-referrer`. Never place the ticket in a query string, browser history, analytics, or application logs.

The ticket is not a general bearer token: it is valid only at the bootstrap endpoint and only for creating one web session.

## Access-token refresh

```http
POST /api/v1/mobile/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Accept: application/json

grant_type=refresh_token&
client_id=org.loomio.mobile.ios&
refresh_token=lm_rt_<opaque-random-value>
```

Each successful refresh rotates the refresh token and returns a new access/refresh pair. The old refresh token is marked consumed atomically. Reuse of a consumed refresh token revokes the entire token family and device grant, requiring browser authentication again.

Native API requests use `Authorization: Bearer`. Cookie authentication is not accepted on `/api/v1/mobile/*`, and bearer authentication is not accepted by the ordinary web application.

## Device credential storage

- Keep the access token in memory when practical.
- Store the refresh token in Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
- Never store either token in `UserDefaults`, WebView storage, logs, analytics, crash metadata, or the push relay.
- Do not synchronize the refresh token through iCloud Keychain or restore it onto another device.
- Redact the `lm_at_`, `lm_rt_`, and `lm_ws_` token families in server and client telemetry.

## Revocation and lifecycle

Current device information:

```http
GET /api/v1/mobile/device
Authorization: Bearer <access-token>
```

Disconnect:

```http
DELETE /api/v1/mobile/device
Authorization: Bearer <access-token>
```

Deletion atomically revokes the device grant, all access/refresh tokens, unused web-session tickets, and relay-registration authorizations. It also queues deletion of the relay registration. The app then clears the Keychain credential, host WebView data, local activity, badges, and host-scoped notifications even if remote deletion fails. A failed remote deletion is retained as a non-sensitive revocation tombstone for bounded retry.

Logging out inside Loomio invalidates only the WebView session. It does not silently revoke the device credential. The Settings screen must clearly distinguish “Log out of Loomio” from “Disconnect this device.”

Server-side account suspension, password/security reset when policy requires it, user sign-out-all, and administrator device revocation invalidate both native tokens and the ability to issue new web-session tickets.

## Web-to-native action bridge

The contained Loomio application may invoke a versioned allowlist of native UI actions through the `loomioNative` WebKit message handler. Version 1 supports reading non-sensitive capabilities, opening native Activity or Settings, requesting notification authorization, and sending a test notification.

The app accepts messages only from the main frame while it is displaying the exact connected HTTPS origin. It rejects subframes, cross-origin documents, unknown versions, and unknown action names. Responses contain only platform and notification status; they never contain access tokens, refresh tokens, device identifiers, APNs tokens, cookies, relay credentials, arbitrary URLs, or Keychain errors. Ordinary Safari does not expose the handler and retains the existing web behavior.

This bridge is not a general RPC mechanism. New actions require an app release, an explicit enum case, a bounded response schema, and a security review. Actions must not evaluate code, navigate to a host-supplied native URL, read native storage, or return credentials.

## Required scopes

| Scope | Purpose |
| --- | --- |
| `activity:read` | Fetch the native recent-activity inbox and unread state. |
| `activity:write` | Mark activity read or unread. |
| `notifications:manage` | Read and update mobile notification preferences and request a test notification. |
| `relay:register` | Request a short-lived assertion authorizing relay registration. |
| `web_session:create` | Create one-time WebView bootstrap tickets. |
| `device:revoke` | Revoke the current device grant. |

The first release uses this fixed scope set. The host confirmation page shows it in user-facing language. Future protocol versions may negotiate smaller sets.

## Server persistence

Suggested logical records; names may follow Loomio conventions:

- `mobile_devices`: UUID, user, display name, platform, protocol version, created/last-seen/revoked timestamps.
- `mobile_authorization_codes`: code digest, user, client, redirect URI, PKCE challenge, expiry, used timestamp.
- `mobile_refresh_tokens`: token digest, device, token-family ID, parent token, issued/expiry/consumed timestamps.
- `mobile_access_tokens`: token digest, device, scopes, expiry and revoked timestamps; alternatively use the existing opaque-token store if it has equivalent semantics.
- `mobile_web_session_tickets`: ticket digest, device, expiry and consumed timestamps.

Store token digests using a keyed server-side hash so a database read alone does not reveal active bearer credentials. Enforce unique digests and use database transactions/locking for every single-use transition.

## Cloudflare boundary

The authorization endpoint remains protected normally because it runs in the system browser.

The following machine/WebView endpoints must not receive an interactive Cloudflare challenge:

- `GET /api/v1/mobile/config`
- `POST /api/v1/mobile/token`
- `POST /api/v1/mobile/web-session-tickets`
- `POST /mobile/web-session`
- Authenticated `/api/v1/mobile/*` endpoints

Configure narrowly scoped rules that skip only interactive challenge or bot checks incompatible with these clients. Keep TLS, managed WAF rules where compatible, DDoS protection, strict methods, body-size limits, origin rate limits, credential validation, and audit logging. Never exempt all `/mobile/*`, because `/mobile/authorize` is browser-facing.

Private-host documentation must describe equivalent controls without requiring Cloudflare.

## Error contract

API errors use a stable code and generic message:

```json
{
  "error": "invalid_grant",
  "error_description": "The authorization could not be completed."
}
```

Supported token errors include `invalid_request`, `invalid_client`, `invalid_grant`, `unsupported_grant_type`, and `temporarily_unavailable`. Authenticated APIs additionally use `invalid_token`, `insufficient_scope`, and `device_revoked`.

Do not reveal whether a code, ticket, token, user, or device exists. Apply uniform response timing where practical and rate-limit by origin signals plus hashed credential prefix.

## Audit events

Record without raw credentials:

- Authorization requested, approved, denied, expired, and consumed.
- Device created, renamed, refreshed, disconnected, administratively revoked, and refresh-token reuse detected.
- Web-session ticket issued, consumed, expired, and replayed.
- Relay-registration assertion issued and revoked.

Expose active mobile devices and their last-used timestamps in the user's Loomio security settings, with remote revocation.

## Acceptance and security tests

At minimum, automate:

1. Successful password, passkey where configured, MFA, and SSO login through `ASWebAuthenticationSession`.
2. Existing browser login reuse and user cancellation.
3. Cloudflare completion in the system session and no Cloudflare challenge on machine/bootstrap routes.
4. Wrong/missing/duplicated `state`, wrong callback path, callback host substitution, and unsolicited callbacks.
5. Plain PKCE rejection, incorrect verifier, authorization-code expiry, replay, and concurrent exchange.
6. Bootstrap-ticket expiry, replay, query-string rejection, concurrent use, revoked device, and cross-host use.
7. Access expiry, refresh rotation, concurrent refresh, consumed-token reuse detection, and token-family revocation.
8. Session fixation prevention and creation of the expected Secure, HttpOnly cookie.
9. Loomio logout versus complete device disconnect.
10. Suspended/deleted users, sign-out-all, administrator revocation, and relay deletion retry.
11. Secrets absent from logs, analytics, URLs, crash reports, WebView storage, backups, and relay requests.
12. Discovery redirects, cross-origin endpoints, malformed JSON, unsupported versions, and private-host incompatibility UI.

## Explicit non-goals

- Sharing or copying Safari/Authentication Services cookies into `WKWebView`.
- Collecting a Loomio password in native UI.
- Passing the WebView cookie to native APIs or the relay.
- Spoofing Safari or transferring Cloudflare clearance cookies.
- Making the relay responsible for Loomio authentication or authorization.
- Supporting arbitrary OAuth clients or redirect URIs in protocol v1.
