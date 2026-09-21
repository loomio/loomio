# Authentication design

Loomio supports two instance-level authentication modes: mixed authentication and SSO-only authentication. The mode controls both the sign-in interface and every server endpoint that can create or recover a local session.

## Mixed authentication

Mixed-authentication sites can offer Loomio-managed passkeys, email and password sign-in, emailed sign-in codes, native account creation, and configured identity providers such as Google, OAuth, or SAML. A returning user can select **Sign in with a passkey** before entering an email address. Discoverable passkeys let the browser or authenticator identify the account without a public email lookup.

Password sign-in uses an email address and password. Its response does not distinguish an unknown email address, an account without a password, a locked account, or an incorrect password. Emailed sign-in-code requests always return the same browser response whether or not the address belongs to an account. Account creation verifies control of the supplied email address before establishing a session.

Passkeys are registered only from a session created within the last ten minutes. Registration requires user verification, creates a discoverable credential, and allows several named credentials per account. Removing a passkey also requires a session created within the last ten minutes. Authentication requires user verification and looks up the account from the credential identifier returned by the authenticator. Passkey challenges are single-use and stored in the encrypted session cookie. Passkey option and verification endpoints are rate-limited but do not use Turnstile because the signed, server-generated WebAuthn challenge provides replay protection and proves possession of the credential.

WebAuthn uses the existing `CANONICAL_HOST` as its relying-party ID and builds the allowed origin from `CANONICAL_HOST`, optional `CANONICAL_PORT`, and the presence of `FORCE_SSL`. No passkey-specific environment variable or server secret is required. Authenticators retain private keys; Loomio stores credential public keys and protects challenges with its existing encrypted session configuration. Development and test environments without `CANONICAL_HOST` use the request host and origin.

Turnstile remains on password authentication, emailed sign-in-code requests, and unauthenticated account creation. These flows accept attacker-controlled email addresses or reusable secrets and retain their existing automated-abuse protections.

## SSO-only authentication

Private hosts can set `FEATURES_DISABLE_LOCAL_LOGIN`. The public sign-in screen then contains only the configured identity-provider buttons. Password authentication, emailed sign-in codes, native registration, Loomio-managed passkey registration, and Loomio-managed passkey authentication are rejected by the server as well as hidden by the client.

`FEATURES_DISABLE_EMAIL_LOGIN` remains a deprecated compatibility alias with the same behavior. Environment-variable presence enables either restriction; operators must omit both variables to enable local authentication.

An SSO-only deployment should use passkeys through its identity provider rather than storing a separate Loomio passkey. This preserves identity-provider suspension, multifactor authentication, and access policies. Operator recovery from a broken SSO configuration is an operational procedure and is not exposed as a routine public sign-in method.

## Account enumeration

Responses must not expose whether an email belongs to an account, whether the account has a password or passkey, its profile details, or whether it is locked or inactive. The client must not use an email-status lookup to choose a sign-in form or begin an account merge. Sign-in-code and merge-verification requests return the same response whether or not an account exists. Invitations and verified emailed links may display account-specific information because possession of the link demonstrates access to the destination mailbox.

Rate limits apply by verified client address and, where an email is accepted, by normalized email. Equivalent success or failure cases use the same HTTP status and response shape. Password verification performs a password-hash operation even when an account cannot be found to reduce timing differences.

## Session behavior

Every successful method creates a new Loomio session through the shared sign-in path, updates sign-in audit fields, clears failed password attempts, and applies pending invitation or participation actions. Authentication method metrics distinguish password, email code, passkey, OAuth, and SAML without recording credentials. After code sign-in, a user without a password may add a passkey, set a password, or dismiss the prompt. Logout revokes the current Loomio session in both mixed-authentication and SSO-only modes.

## Security review plan

Review authentication changes against each supported deployment mode: mixed authentication with and without account creation, invitation-only mixed authentication, and SSO-only authentication. For every mode, test signed-out users, active and inactive accounts, signed-in users, users authenticated only by an unsubscribe token, and sessions older than the recent-authentication window.

For email privacy, compare status codes, response bodies, client messages, and observable timing for known and unknown addresses across password sign-in, sign-in-code requests, registration, profile changes, and account merging. Confirm that rate limits and Turnstile still protect the email and reusable-secret entry points, while passkey endpoints remain email-free.

For passkeys, verify relying-party ID and origin binding, challenge expiry and single use, required user verification, discoverable-credential behavior, unknown credential IDs, user-handle matching, signature counters, inactive users, registration, listing, account-scoped removal, and recent-authentication enforcement. Exercise authenticators on the supported browser and platform combinations before release.

For sessions and SSO, verify session creation and rotation for every authentication method, cookie security, CSRF protection, logout and dependent-session cleanup, SSO-only endpoint enforcement, and logout from SSO-only deployments. Run focused controller tests, the authentication browser suite, static analysis, dependency auditing, and a manual test against a production-like HTTPS hostname before deployment.
