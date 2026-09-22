# Authentication branch audit response

This response records the disposition of the findings in the authentication branch audit prepared on 2026-09-22. The superseded audit plan has been removed; the lasting authentication policy is documented in `docs/system/authentication.md`. Detailed verification rules remain documented by the implementation and focused tests.

## Resolved findings

1. **SSO-only account completion:** fixed. The completion endpoint is available when local login is disabled, while native registration and local authentication remain blocked. A regression test completes an SSO-authenticated account in SSO-only mode.
2. **Server-side challenge consumption:** implemented. Passkey challenges have a five-minute server record bound to ceremony and, for registration, user. Consumption locks and deletes that record. Restoring an old encrypted cookie therefore cannot replay a consumed challenge.
3. **Logout cleanup:** fixed. Logout revokes the database session and resets the complete Rails session cookie, clearing staged completion, pending identities and invitations, and passkey challenges.
4. **Account-completion atomicity and navigation:** fixed. Profile completion and session creation occur in one database transaction. A session-creation failure rolls back the name and legal acceptance, and successful completion returns the protected destination.
5. **Passkey merge behavior:** fixed. Source credentials move to the destination account while retaining the credential-specific WebAuthn user handle used during authentication.
6. **Deactivation and redaction:** clarified and enforced. Deactivation retains credentials but an inactive owner cannot authenticate. Permanent redaction deletes passkeys and clears the WebAuthn account identifier.
7. **Endpoint authorization and freshness:** expanded. Passkey listing and mutation require a full signed-in user; an unsubscribe-token context cannot access them. Registration creation and deletion each independently enforce recent authentication. Listing is account-scoped and returns only display metadata.
8. **WebAuthn negative verification:** expanded. Focused tests reject wrong origins and relying parties, altered signatures, absent user verification, mismatched user handles, unknown credentials, inactive owners, expired and reused challenges, restored-cookie replay, and regressing nonzero counters. A malformed cryptographic signature now produces the generic authentication failure rather than an internal error.
9. **CSRF exception:** retained with narrower evidence. Loomio's helper does not replace Rails CSRF validation. It accepts the SPA's Rails-generated token before Rails rejects a privacy-preserving `null` Origin, but still calls Rails `valid_authenticity_token?`. Tests cover a valid Rails token, a missing token, and matching attacker-controlled cookie/header values.
10. **Credential lifecycle tests:** added for account merging and permanent redaction. Existing focused tests cover registration, authentication, listing, deletion, recent-authentication enforcement, inactive users, and SSO-only rejection.
11. **Account-completion cookie replay:** follow-up verification reproduced a new session after restoring a completion cookie following logout. Completion now uses an expiring server record consumed atomically with the profile and session. Logout, replacement completion authentication, and successful sign-in revoke pending proof. Request-level regressions use actual saved cookies with CSRF protection enabled, including logout before completion and switching accounts. Legacy cookie-only completion state is rejected.
12. **Independent RP and complete SSO-flow coverage:** registration now tests an incorrect relying party with the correct origin, and authentication tests an incorrect relying party separately from an incorrect origin. OAuth and SAML integration tests perform initiation, callback, and completion in SSO-only mode, with and without provider names, then check that native registration and authentication remain forbidden. Provider responses are mocked; these tests do not validate a live identity provider.

## Accepted design decisions

- Email is Loomio's final automated recovery method. If email and all configured credentials are unavailable, customer support must verify the user and repair access manually.
- Existing authenticated sessions and passkeys are not invalidated merely because the configured terms URL later changes. Loomio may update terms and notify users by email.
- Changing `CANONICAL_HOST` intentionally invalidates existing passkeys because it changes the WebAuthn relying party. Users recover by email and register replacement passkeys; operators may remove invalid credentials. No special migration mechanism is planned.
- Deactivation is reversible and retains credentials. Redaction is permanent and removes credentials.
- Turnstile remains on the email/password/account-creation paths that accept attacker-controlled identifiers or reusable secrets. Passkey ceremonies use signed WebAuthn challenges and do not use Turnstile.

## Deployment verification still assigned to the operator

The branch still requires testing on `loomiotest.org` before deployment: production-like HTTPS and proxy behavior, supported physical passkey devices and browsers, and recovery behavior under the deployed canonical host. These are environment checks rather than unresolved code findings.

## Verification commands

The focused Rails suites cover passkeys, completion, sessions, merging, redaction, login-code behavior, invitations, CSRF behavior, and deployment flags. On 2026-09-22 these completed with 265 tests and 1,058 assertions, with no failures or errors. The authentication Nightwatch suite then completed with 207 assertions, covering browser registration, sign-in, removal, code and password paths, account completion, invitations, and credential-prompt decisions. Rails and E2E suites must be run sequentially because both use `loomio_test`.

After the completion-replay fix, the same Rails suites plus the new completion/SSO integration suites and the original isolated replay reproducer passed with 277 tests and 1,217 assertions. The direct security review checked that completion authority comes from the server record, provider-managed names use server state, expiry and consumption are checked under locks, and failed validation/session creation preserves retry authority. The new migration was applied successfully to local test and development databases. Previously staged cookie-only completions intentionally require fresh authentication after upgrading.

The authentication browser suite was rerun after this fix and passed all 207 assertions. The run logged a transient fixture-reset database deadlock and browser interaction retries, but no testcase failed. Production-like HTTPS, physical authenticators, and live identity-provider verification remain operator checks.
