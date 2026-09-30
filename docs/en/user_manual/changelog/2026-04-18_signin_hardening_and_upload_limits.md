# Sign-in hardening and upload limits

## Bot protection on sign-in and signup

Password sign-in, magic-link ("login token") requests, and new signup/trial creation now pass through a Cloudflare Turnstile challenge to deter bots and credential-stuffing. It's skipped automatically for people completing a login by clicking an emailed magic link, and for sessions where a valid login code has already been supplied, so returning users aren't challenged twice.

## Upload size limits

Direct file uploads are now capped by account tier: 25 MB for trial accounts and 1 GB for paid accounts. Uploads over the limit are rejected up front with a clear "file too large" message instead of failing partway through.
