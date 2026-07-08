# Single sign-on improvements

Two fixes make organization single sign-on (SSO) more reliable.

## Locked profile fields

When an instance is configured to force SSO-managed attributes, a member's name, email, and username fields become read-only on their profile. These values are managed by the identity provider and can no longer be edited from within Loomio.

## Login reliability

Fixed crashes where OAuth/SAML sign-in would fail with a server error, or show an "email already taken" error for someone who already had a Loomio account under the same email but no linked SSO identity. Signing in now correctly finds and links the existing account instead of erroring.
