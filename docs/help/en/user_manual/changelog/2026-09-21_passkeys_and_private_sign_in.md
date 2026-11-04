# Passkeys and private sign-in

You can now sign in to Loomio with a passkey. A passkey is a secure credential saved on your device or in your password manager. You unlock it with your device's usual method, such as a fingerprint, face scan, or PIN; Loomio verifies it without receiving the credential itself. A passkey works only for Loomio's site address, which helps protect against phishing. You can sign in quickly without remembering a password or waiting for an emailed code, making it Loomio's easiest and most secure sign-in method.

If your device supports passkeys and you sign in with a password or emailed code, Loomio offers to add one if you do not already have one. You can skip the offer and add, name, or remove passkeys from your profile later. On your next visit, select **Use a passkey** and unlock it to sign in without entering an email address, password, or code. Password and emailed-code sign-in remain available.

Sign-in and account-merge requests now prevent account enumeration: browser responses do not reveal whether an email address belongs to a Loomio account. Sites that allow account creation continue to show **Create account**; invitation-only sites show it only during an invitation flow.

New accounts complete any missing name or terms acceptance after verification. People who have already used Loomio can continue signing in even if the site has no recorded terms acceptance for them. Site operators can require those accounts to confirm the terms later.

Private-site operators can set `FEATURES_DISABLE_LOCAL_LOGIN` to require configured single sign-on. This disables password, emailed-code, native account-creation, and Loomio-managed passkey endpoints as well as removing those choices from the sign-in screen. `FEATURES_DISABLE_EMAIL_LOGIN` remains available as a compatibility alias.
