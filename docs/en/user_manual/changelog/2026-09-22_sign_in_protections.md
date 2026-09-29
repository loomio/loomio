# Sign-in protections

Deactivated accounts can no longer use an existing browser session to read or change account information. Password sign-in now enforces the configured failed-attempt limit, and per-email rate limits apply to requests from the web app.

Old sessions from the previous authentication system are no longer accepted. People still using one of those sessions will need to sign in again. Current sessions are unaffected.

An SSO connection already linked to an account cannot be reassigned by reusing an earlier pending sign-in request.
