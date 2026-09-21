# Signing in

The sign-in methods available on Loomio depend on how the site operator has configured authentication. Loomio.com and mixed-authentication sites can offer passkeys, email and password sign-in, emailed sign-in codes, and providers such as Google. A private site may require its organization single sign-on provider instead.

![The Loomio sign-in form with passkey, email, password, and emailed-code options](sign_in_email.png)

## Sign in with a passkey

Select **Sign in with a passkey**. Your browser or device shows the Loomio passkeys available to you and asks you to unlock the selected passkey with its normal screen lock, fingerprint, face recognition, PIN, or security key. You do not enter an email address first.

You can add, name, and remove passkeys from your profile. For security, Loomio may ask you to sign in again before changing them. Give each passkey a recognizable name such as “Work laptop” or “Phone”. Passkeys are tied to the Loomio site where they were created and may be synchronized by your device or password manager.

## Sign in with email and password

Enter your email address and password, then select **Sign in**. For account privacy, Loomio uses the same error when the email or password cannot be used to sign in.

If you do not have a password or cannot remember it, select **Email me a sign-in code** instead.

## Get a sign-in code

Enter your email address and select **Email me a sign-in code**. Loomio displays the same confirmation whether or not the address belongs to an account, so another person cannot use the form to discover who uses Loomio.

If the address belongs to your account, Loomio sends a six-digit code. Return to the sign-in form, enter the code, and select **Sign in**. Sign-in codes normally expire after 24 hours and cannot be reused. Check your spam folder if the message does not arrive, and make sure you entered the address associated with your account.

After signing in with a code, Loomio may offer to add a passkey or set a password. Both are optional; you can continue using emailed codes.

## Create an account

On sites that allow people to create accounts without an invitation, select **Create account** and follow the email-verification steps. Sites that require an invitation do not show this option unless you are following an invitation link.

For privacy, use the same email address that received your group invitation. If you have accounts under more than one address, you can [merge your accounts](/en/user_manual/users/merge_accounts).

## Single sign-on

Loomio supports Google, SAML, and OAuth identity providers when configured by the site operator. Select the provider button and authenticate with that provider. If an existing Loomio account has the same verified email address, Loomio can link the provider identity to that account. An organization may manage your name and email through its identity provider, in which case those fields cannot be edited in your Loomio profile.

An SSO-only private site shows only its organization sign-in option. It does not offer Loomio-managed passwords, emailed sign-in codes, native account creation, or Loomio-managed passkeys. If the organization uses passkeys, its identity provider asks for them during SSO.

## Sign out

Open the sidebar, select your name, then select **Sign out**. On a shared computer, sign out when you finish rather than closing only the browser tab.
