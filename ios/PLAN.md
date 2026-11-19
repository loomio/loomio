# Loomio mobile handover

## Goal

Build an iOS companion that connects to several user-selected Loomio hosts at once, provides native notifications and activity entry points, and contains the complete existing Loomio web application for reading, Tiptap editing, polls, and administration. Do not reimplement Loomio workflows natively.

Model each connection by host ID/origin, with its own credentials, token refresh task, website data store, activity and push registration. The native shell selects a server without disconnecting the others and combines recent activity across servers.

## Agreed architecture

- Use SwiftUI for the native shell and a separate isolated `WKWebView` for each connected Loomio host.
- Native screens cover host connection, recent activity, push status/settings, test notification, disconnect, and error/offline states.
- The web view runs the host's existing Vue application, including Tiptap. Read-only rich content is ordinary sanitized HTML; Tiptap is needed only for editing.
- Notification links open the exact page inside the contained Loomio application. Unrelated external links open in the system browser.
- Authenticate through an Apple system web-authentication session rather than inside `WKWebView`. This is required because Cloudflare challenges can block or loop in embedded browsers.
- Register an unauthenticated `loomio://connect?config=...` URL for websites and QR codes to propose a host configuration. Always validate and confirm it before fetching configuration or starting authentication.
- Build and operate a separate push relay that can serve Loomio Cloud and private hosts. The Ruby/SQLite implementation and deployment instructions are under `push-relay/`. The shared relay is configured for loomio.com, loomio.nz and loomio.eu; each additional host requires separate configuration.
- Do not use Capacitor `server.url`; it is documented as a development/live-reload facility rather than a production remote-app architecture.

## Authentication architecture

The v1 server and app contract is specified in [`docs/MOBILE_AUTH_PROTOCOL.md`](docs/MOBILE_AUTH_PROTOCOL.md).

- Start login with `ASWebAuthenticationSession` so passwords, passkeys, SSO, and Cloudflare checks run in the system-managed browser authentication context.
- Add Loomio mobile-auth endpoints that support Authorization Code-style one-time codes with PKCE, a cryptographically random `state`, a short expiry, single use, and strict binding to the initiating host and device attempt.
- After successful browser authentication, redirect to an app-owned callback. The callback contains only the short-lived authorization code and state, never a password, session cookie, bearer credential, or confidential user data.
- Exchange the code directly with the selected Loomio host. Return a narrow revocable device credential for native activity/push APIs and a separate one-time web-session bootstrap ticket.
- Load the bootstrap ticket through a same-origin Loomio endpoint inside `WKWebView`. The server consumes it once, sets the normal Secure, HttpOnly Loomio session cookie, and redirects into the web application. Do not copy cookies from the system browser or expose either session to JavaScript or the push relay.
- Configure Cloudflare so the narrowly scoped callback, code-exchange, and bootstrap endpoints do not require an interactive embedded-browser challenge. Retain TLS, WAF protections, rate limits, replay protection, expiry, and server-side validation; do not bypass Cloudflare broadly or rely on a spoofable user-agent exception.
- Keep logout and disconnect distinct: Loomio logout ends the web session, while disconnect additionally revokes the device credential, deletes the relay registration, and removes host-scoped local data.
- Private hosts implement the same versioned protocol. Hosts that do not support mobile authentication should fail with a clear compatibility message rather than falling back to collecting passwords natively.

## Push relay architecture

- Create a small independently deployable relay service rather than placing APNs credentials on each Loomio host.
- Consume an opaque relay-registration authorization derived from the host-issued, revocable device credential. The relay must never receive the user's Loomio password, browser session, or host API credential.
- The iOS app registers its APNs token, selected host ID/origin, environment, and opaque device credential with the relay. Handle APNs token rotation and make registration idempotent.
- Loomio hosts send authenticated notification events to the relay. Define replay protection, request signing, rate limits, retry behaviour, and host/device revocation from the start.
- Keep APNs payloads generic and opaque. A payload may identify the host registration and event, but must not contain confidential discussion, poll, membership, or user content.
- After launch, the app fetches authorized activity details and validates every destination against the connected host before displaying or navigating to it.
- The relay must support device registration, deletion, test notification, APNs delivery-error cleanup, and production/sandbox APNs environments.
- Serve recent activity and unread state directly from each Loomio host. Keep confidential activity data out of the relay.

## Security invariants

- Treat every selected host as untrusted native code input, even when trusted by its user.
- Enable JavaScript in the Loomio web view, but expose only the versioned, main-frame, same-origin allowlist of native actions. Never expose native credentials, tokens, arbitrary selectors, URLs, or method invocation to host JavaScript.
- Allow only HTTPS production hosts. Validate every notification and navigation destination against the connected host.
- Reject unsafe schemes and open unrelated origins in the system browser. Explicitly handle required SSO/authentication origins rather than permitting arbitrary navigation.
- Never attempt to bypass Cloudflare by spoofing Safari, injecting challenge cookies, or weakening web-view isolation. Use the explicit mobile authentication protocol.
- Keep relay/device credentials in Keychain, outside the web view.
- On disconnect or host replacement, remove cookies, website data, cached content, relay registration, credentials, and pending notifications belonging to that host.
- Keep APNs payloads generic and opaque; fetch confidential notification details after launch.
- Conduct a focused security review of authentication, sessions, host switching, notification disclosure, and any poll data displayed natively.

## Minimum App Store submission

The app must provide utility beyond a repackaged website and must remain usable when push permission is denied. Include:

- Connect multiple Loomio hosts and switch between them without signing out.
- Refreshable recent-activity inbox with unread state.
- Native notification status and test notification controls.
- A prominent Open Loomio action and direct routing from activity items.
- The complete functional Loomio workspace in the isolated web view.
- Disconnect/device-revocation and privacy controls.
- A seeded review host, review account, sample activity, and clear App Review instructions.

Hide subscription purchase, upgrade, checkout, and other external-purchase calls to action in the app context. Confirm that user-generated-content reporting/moderation paths remain available.

## First engineering milestone

1. Create an iOS SwiftUI project with configurable app name, bundle identifier, deployment target, and selected-host storage.
2. Implement host entry and strict HTTPS origin validation.
3. Specify and implement the system-browser mobile login, PKCE callback, device credential, and one-time `WKWebView` session-bootstrap protocol, including the narrowly scoped Cloudflare configuration.
4. Implement the isolated `WKWebView`, navigation policy, external-link routing, persistent login, and complete disconnect cleanup.
5. Verify login/logout, Cloudflare handling, password AutoFill, passkeys where supported, SSO redirects, Tiptap and keyboard behaviour, polls, uploads/downloads, back navigation, ActionCable/Hocuspocus reconnection, and app background/foreground transitions.
6. Add unit tests for URL/origin and authentication-callback policy, plus XCUITests for connection, browser login, persistence, unsafe navigation, and disconnect cleanup.
7. Specify the device-registration, notification-event, revocation, and activity protocols after the authenticated web-container spike is sound. Complete.
8. Build the minimum push relay, add the required Loomio host integration, then connect the native activity and notification shell to APNs and the relay. Implementation, relay deployment, and APNs key provisioning are complete for loomio.com. A native Settings test notification was verified on an iPhone; background activity and tap behavior remain to be checked.
9. Add a versioned, allowlisted same-origin bridge so selected Loomio web controls can invoke native Activity, Settings, and notification actions. Complete.
10. Test authentication replay and expiry, callback substitution, token rotation, duplicate events, retries, invalid credentials, revoked devices, host switching, notification disclosure, and APNs sandbox/production separation.
11. Submit the smallest complete version to App Review with manual release before investing in Android.

## Environment and release notes

The development machine has Xcode 26.2, Swift 6.2.3, and iOS 26.3 simulator devices available through CoreSimulator. The app targets iOS 26, and its current unit/UI suite passes on an iPhone 17 Pro simulator. Production signing, Apple Developer agreements, bundle registration, App Store metadata, relay hosting, APNs key provisioning, and release remain human-approved actions. Do not commit certificates, provisioning profiles, relay secrets, APNs signing keys, or Apple credentials.

## Multi-server support

The native server menu adds and switches connections while preserving each open WebView. A combined activity list namespaces item IDs by server and routes each item back to its own origin. All connected servers register the device’s APNs token independently; opaque relay registration IDs route both notification taps and foreground refresh signals to the owning connection. Unknown registrations open combined activity instead of guessing a server.

Existing single-server installations retain their connection UUID, Keychain item and legacy WebKit store. New connections use persistent WebKit stores identified by host UUID, preventing cookies from crossing between related domains. Disconnect waits for an in-flight refresh rotation before device revocation and clears only the removed connection. Refresh responses preserve push metadata written while the request was in flight.

The relay scopes APNs identity uniqueness and replacement to host origin plus environment and token digest. Migration `002_scope_apns_identity_to_host.sql` preserves existing registrations and delivery state. Registration UUIDs stay bound to their original host; a different host cannot overwrite them. The wire protocol remains version 1.

The focused security review checked origin-bound configuration and bootstrap URLs, per-connection Keychain ownership and token rotation, main-frame/same-origin bridge access bound to the calling connection, isolated website data stores, opaque registration-ID notification routing, activity destination validation, and disconnect cleanup. Regression tests cover cross-server credentials, cookie isolation and selective cleanup, duplicate activity IDs, concurrent refresh and push registration, legacy migration, and stale notification registrations.

## Open decisions

- Apple push notifications: the Ruby/SQLite relay and separate production/sandbox APNs keys are deployed, and loomio.com is configured. Native Settings test delivery was confirmed on an iPhone on 2026-11-13. Verify background activity, tap destinations, revocation, and physical-device delivery in both build environments; the environment of the first phone test was not explicitly recorded.
- Later interface idea: hide the mobile title bar while scrolling down, and reveal it when scrolling up or while data is loading. Keep content position stable during these transitions.

- Final production bundle identifier/client ID and callback scheme replacing the provisional values in the v1 mobile-auth specification.
- Cloudflare rules for the mobile-auth endpoints and how equivalent controls are documented for private hosts using other edge providers.
- Ongoing relay monitoring, ownership, and operating budget. The implementation is a standalone Ruby Rack service backed by SQLite; operator procedures are in `push-relay/deploy/README.md`.
- Offline caching policy for native recent activity beyond the current in-memory, paginated implementation.
- APNs key ownership and production secret provisioning. Sandbox/production routing, transient retry, permanent-token cleanup, and bounded relay metadata retention are implemented.
- Which authentication/SSO origins a connected host may authorize.
- Whether later desktop clients share only the protocol or also adopt a cross-platform UI toolkit.
