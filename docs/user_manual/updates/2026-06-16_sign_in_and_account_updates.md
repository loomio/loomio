# Sign-in and account updates

Several sign-in and account flows were improved.

## Login-code rate limits

When a login-code request is rate limited, Loomio now shows a clearer error message instead of a generic failure.

This helps people understand that they may need to wait before requesting another login link or code.

## Password prompt after login-code sign-in

People who sign in with a login code may now be prompted to set a password.

This is useful for people who want a faster sign-in option next time, or who prefer not to rely on email codes for every session.

The prompt is optional. It offers a direct Set password action from the signed-in session.

## OAuth profile photos

When signing in through an OAuth provider, Loomio can now apply the profile picture supplied by that provider.

This makes new and returning accounts feel more complete after social or organization-based sign-in.

## Website sign-in awareness

Loomio now sets a signed-in browser cookie that can be used by the Loomio website to detect whether someone is already signed in.

This helps public website and app flows stay in sync.
