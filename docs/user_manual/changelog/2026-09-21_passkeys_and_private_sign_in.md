# Passkeys and private sign-in

People can sign in without entering an email address by selecting **Sign in with a passkey** and choosing a Loomio passkey saved on their device or in their password manager. Add, name, and remove passkeys from your profile after signing in. After signing in with an emailed code, people without a password can choose to add a passkey, set a password, or continue without either.

Email and password failures no longer reveal whether an email address has a Loomio account, and requests for emailed sign-in codes or account-merge verification always show the same browser confirmation. Sites that allow account creation continue to show **Create account**; invitation-only sites show it only during an invitation flow.

Private-site operators can set `FEATURES_DISABLE_LOCAL_LOGIN` to require configured single sign-on. This disables password, emailed-code, native account-creation, and Loomio-managed passkey endpoints as well as removing those choices from the sign-in screen. `FEATURES_DISABLE_EMAIL_LOGIN` remains available as a compatibility alias.
