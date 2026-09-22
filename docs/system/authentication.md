# Authentication design

Loomio supports two instance-level authentication modes: mixed authentication and SSO-only authentication. The mode controls both the sign-in interface and every server endpoint that can create or recover a local session.

## Mixed authentication

Mixed-authentication sites can offer Loomio-managed passkeys, email and password sign-in, emailed sign-in codes, native account creation, and configured identity providers such as Google, OAuth, or SAML. A returning user can select **Sign in with a passkey** before entering an email address. Discoverable passkeys let the browser or authenticator identify the account without a public email lookup.

Password sign-in uses an email address and password. Its response does not distinguish an unknown email address, an account without a password, a locked account, or an incorrect password. By default, emailed sign-in-code requests return the same browser response whether or not the address belongs to an account, and say that a code will be sent if the account exists. An operator may set `FEATURES_REVEAL_EMAIL_ACCOUNT_STATUS` to tell a person that an entered email has no account or belongs to a deactivated account; this intentionally permits account enumeration and should only be enabled when that disclosure is acceptable. Account creation verifies control of the supplied email address before establishing a session.

Passkeys are registered only from a session created within the last ten minutes. Registration requires user verification, creates a discoverable credential, and allows several named credentials per account. Removing a passkey also requires a session created within the last ten minutes. Authentication requires user verification and looks up the account from the credential identifier returned by the authenticator. Each challenge is bound to its ceremony and, for registration, its user. The browser cookie carries the challenge while a short-lived server record makes it single-use even if an older encrypted cookie is restored.

WebAuthn uses the existing `CANONICAL_HOST` as its relying-party ID and builds the allowed origin from `CANONICAL_HOST`, optional `CANONICAL_PORT`, and the presence of `FORCE_SSL`. No passkey-specific environment variable or server secret is required. Authenticators retain private keys; Loomio stores credential public keys and protects challenges with its existing encrypted session configuration. Development and test environments without `CANONICAL_HOST` use the request host and origin.

Turnstile remains on password authentication, emailed sign-in-code requests, and unauthenticated account creation. These flows accept attacker-controlled email addresses or reusable secrets and retain their existing automated-abuse protections.

Email is the final automated recovery method for Loomio-managed authentication. If email delivery is unavailable and the user has no working password or passkey, customer support must verify the person and repair access manually. Removing the last passkey is therefore allowed. If an operator changes `CANONICAL_HOST`, existing passkeys no longer match the relying party; users recover through email and register replacement passkeys, and an operator may remove invalid credentials.

## SSO-only authentication

Private hosts can set `FEATURES_DISABLE_LOCAL_LOGIN`. The public sign-in screen then contains only the configured identity-provider buttons. Password authentication, emailed sign-in codes, native registration, Loomio-managed passkey registration, and Loomio-managed passkey authentication are rejected by the server as well as hidden by the client.

`FEATURES_DISABLE_EMAIL_LOGIN` remains a deprecated compatibility alias with the same behavior. Environment-variable presence enables either restriction; operators must omit both variables to enable local authentication.

An SSO-only deployment should use passkeys through its identity provider rather than storing a separate Loomio passkey. This preserves identity-provider suspension, multifactor authentication, and access policies. Operator recovery from a broken SSO configuration is an operational procedure and is not exposed as a routine public sign-in method.

Account completion remains available after a successful SSO callback when the provider did not supply every required profile or legal-consent field. This completes an already authenticated SSO identity and does not enable native registration or local authentication.

## Account enumeration

Unless `FEATURES_REVEAL_EMAIL_ACCOUNT_STATUS` is explicitly enabled, responses must not expose whether an email belongs to an account, whether the account has a password or passkey, its profile details, or whether it is locked or inactive. The client must not use an email-status lookup to choose a sign-in form or begin an account merge. Sign-in-code and merge-verification requests return the same response whether or not an account exists. The opt-in setting changes only the sign-in-code response for unknown and deactivated accounts; password authentication and merge verification remain non-disclosing. Invitations and verified emailed links may display account-specific information because possession of the link demonstrates access to the destination mailbox.

Rate limits apply by verified client address and, where an email is accepted, by normalized email. Equivalent success or failure cases use the same HTTP status and response shape. Password verification performs a password-hash operation even when an account cannot be found to reduce timing differences.

## Session behavior

Every successful method creates a new Loomio session through the shared sign-in path, updates sign-in audit fields, clears failed password attempts, and applies pending invitation or participation actions. Authentication method metrics distinguish password, email code, passkey, OAuth, and SAML without recording credentials.

An account must have a name and, when terms are configured, accept those terms before an application session is created. This completion step also applies after SSO when the provider does not supply a name. If the provider supplies a managed name and no legal acceptance is required, SSO creates the session immediately. Loomio does not force an already authenticated user or an existing passkey holder through completion merely because the configured terms URL later changes.

After email-code sign-in, a supported device offers a passkey when the account has none. A device without passkey support offers a password when the account has none. Dismissing either offer is remembered in that browser. The sign-in-code form does not advertise a password separately because the post-authentication prompt is the supported setup path.

Logout revokes the current database session and resets the entire Rails browser session in both mixed-authentication and SSO-only modes. This clears staged account completion, pending identity and invitation proofs, and outstanding passkey challenges.

Loomio retains Rails authenticity-token validation for state-changing browser requests. The SPA compatibility path accommodates browsers that report a privacy-preserving `null` Origin only when the request supplies a token that Rails validates against the encrypted session; matching arbitrary cookie and header values is not sufficient.

Account-completion authentication is backed by a server record with a fifteen-minute expiry. Completion consumes that record in the same transaction as the profile update and new session. Logout, replacement authentication for completion, and successful sign-in revoke the browser's pending record, so restoring an older encrypted cookie cannot reuse it. Failed validation or session creation leaves the record available for retry within its expiry. Deployment of this change requires the account-completion-proof migration; previously staged cookie-only completions must authenticate again.

## Account lifecycle

Account merging transfers the source account's passkeys to the destination. Each credential retains the user handle with which it was registered so it remains usable after ownership changes. Deactivation is reversible and retains credentials, but inactive users cannot authenticate. Permanent redaction deletes passkeys and clears the account's WebAuthn identifier.

## Security review plan

Review authentication changes against each supported deployment mode: mixed authentication with and without account creation, invitation-only mixed authentication, and SSO-only authentication. For every mode, test signed-out users, active and inactive accounts, signed-in users, users authenticated only by an unsubscribe token, and sessions older than the recent-authentication window.

For email privacy, compare status codes, response bodies, client messages, and observable timing for known and unknown addresses across password sign-in, sign-in-code requests, registration, profile changes, and account merging. Confirm that rate limits and Turnstile still protect the email and reusable-secret entry points, while passkey endpoints remain email-free.

For passkeys, verify relying-party ID and origin binding, challenge expiry and server-side single use, required user verification, discoverable-credential behavior, unknown credential IDs, user-handle matching, signature counters, inactive users, registration, listing, account-scoped removal, and recent-authentication enforcement. Exercise authenticators on the supported browser and platform combinations before release.

For sessions and SSO, verify session creation and rotation for every authentication method, cookie security, CSRF protection, logout and dependent-session cleanup, SSO-only endpoint enforcement, and logout from SSO-only deployments. Run focused controller tests, the authentication browser suite, static analysis, dependency auditing, and a manual test against a production-like HTTPS hostname before deployment.
