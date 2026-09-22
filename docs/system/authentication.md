# Authentication design

Loomio supports mixed authentication and SSO-only authentication. Mixed-authentication sites may offer Loomio-managed methods alongside an identity provider. SSO-only sites delegate authentication policy entirely to their identity provider and must not expose Loomio-managed authentication as an alternative route around that policy.

## Email privacy

Loomio does not reveal whether an email address belongs to an account by default. This applies across authentication and account-management workflows so that moving an email field to a different screen does not create a new account-enumeration channel.

Operators may enable `FEATURES_REVEAL_EMAIL_ACCOUNT_STATUS` when telling people that an account is unknown or deactivated is more valuable than concealing account membership. Enabling it deliberately permits enumeration through the sign-in-code workflow; it does not make password authentication or account merging disclose account status.

Possession of an invitation or verified emailed token is different from entering an arbitrary address. Those workflows may reveal information about the account or invitation represented by that secret.

## Recovery

Email is the final automated recovery method for Loomio-managed authentication. Passwords and passkeys provide alternatives when email is inconvenient or unavailable, but they do not replace email as the recovery authority. If a person has no working email, password, or passkey, customer support must verify them and repair access manually.

Passkeys require no Loomio-specific server secret and are bound to the instance's canonical host. Changing that host invalidates existing passkeys by design. People recover through email and register replacements; an operator may remove credentials that can no longer be used.

## Identity-provider trust

An operator who configures OAuth or SAML designates that provider as authoritative for ownership of the email addresses it asserts. The provider must therefore verify those addresses before returning them to Loomio. A provider that allows unverified email claims can take over matching Loomio accounts.

An SSO-only deployment should provide passkeys through its identity provider rather than also enabling Loomio-managed passkeys. This preserves provider-controlled suspension, multifactor authentication, and access policy. Recovery from a broken SSO configuration is an operator procedure, not a public fallback authentication method.

Completing missing profile or legal-consent fields after a successful SSO callback completes an already authenticated identity. It does not enable local registration or local authentication on an SSO-only site.

## Terms

When terms are configured, a person must accept them before their first application session is created. Changing the configured terms URL does not force existing users or passkey holders to accept the terms again. Loomio's terms policy relies on notifying users of later changes rather than versioning acceptance in the authentication system.
