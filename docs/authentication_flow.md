# Authentication Flow Documentation

## Overview

Loomio supports two authentication methods:
1. **Email/Code Sign-In** - Code-based authentication via email, with optional password
2. **OAuth/SSO Sign-In** - Third-party SSO providers (Google, SAML, generic OAuth, Nextcloud, etc.)

Both methods follow the same account linking and verification logic.

## Key Principle

**Email verification is proven through successful authentication.** Users with unverified accounts (created via invitations) can authenticate via code-based email or OAuth/SSO. Upon successful authentication, their email is automatically marked as verified. This enables:
- Seamless onboarding for invited users
- Transparent account linking for new OAuth identities
- Consistent verification status across both auth methods

## Authentication Flows

### Email/Password Sign-In

Email authentication uses a code-based flow for security. Users can optionally set a password.

**Flow:**

**Step 1: Email Entry**
- User enters email address
- System checks if email exists in users table

**Step 2a: Email exists and verified**
- Offer two options:
  - Send sign-in code (always available)
  - Use password (if user has set one)

**Step 2b: Email exists but unverified (from invitation)**
- Treat as signup
- Send sign-in code

**Step 2c: Email doesn't exist**
- Treat as signup
- Send sign-in code

**Step 3: User clicks sign-in code link**
- Link includes secure token
- User authenticated via code
- Set `email_verified: true`
- User can optionally set/update password
- Sign in user

**Result:** User is signed in, email is verified

**Edge Cases:**
- Account is deactivated: Sign-in fails
- Invalid or expired code: Re-send code or offer new flow

---

### OAuth/SSO Sign-In

**Entry Point:** `GET /:provider/oauth?back_to=<path>`

**Step 1: OAuth/SAML Callback**
- OAuth provider redirects with authorization code (OAuth) or SAML response (SAML)
- System validates and extracts identity params (uid, email, name)

**Step 2: Call IdentityService.link_or_create**

Centralized account linking logic via `IdentityService.link_or_create(identity_params:, current_user:)`

The `identity_type` + `uid` pair is unique - one SSO account can only be linked to one Loomio account.

**2a) Identity already exists:**
- Update identity attributes (email/name may have changed in provider)
- Retrieve linked Loomio user
- If user exists: Sign in user
- If no user linked: Set identity as pending (rare case)

**2b) Identity is new:**

Check user's login state:

#### Case A: User not signed in, looking for matching Loomio account

**Step 2b-A1: Search for user by email**
- Look for any user (verified or unverified) with matching email
- If found: Link identity to that user, set `email_verified: true`, sign in
- If not found: Check next step

**Step 2b-A2: No user found by email**
- Create new user account
- Link identity to new user
- Set `email_verified: true`
- Sign in new user

**Result:** User is always signed in with verified email (account linked or new account created)

#### Case B: User already signed in

**Step 2b-B1: Prevent auto-linking new identities**
- Sign out current user
- Create identity as pending (not linked to any user)
- Flash message: "Switching accounts. Please sign in with your new account details."
- Redirect to back_to or dashboard
- User sees `identity_form.vue` to intentionally:
  - Create new account with this identity, or
  - Link this identity to an existing account

**Rationale:** Prevents accidental account confusion when users forget to logout before switching SSO accounts.

---

## Complete Authentication State Machine

| User State | Email/Code Sign-In | OAuth/SSO Sign-In |
|-----------|----------------------|----------------|
| **No account exists** | Send code, user optionally sets password, set `email_verified: true`, sign in | Create account, set `email_verified: true`, sign in |
| **Unverified account exists (from invitation)** | Send code, user optionally sets password, set `email_verified: true`, sign in | Link identity to account, set `email_verified: true`, sign in |
| **Verified account exists** | Send code or ask for password, set `email_verified: true`, sign in | Link identity to account, set `email_verified: true`, sign in |
| **User already signed in, attempting different account** | N/A | Sign out, create pending identity for intentional linking |
| **OAuth identity exists, linked to different user** | N/A | Sign in silently to that user (expected when switching accounts intentionally) |

**Note:** Both auth methods mark `email_verified: true` upon successful authentication (code delivery proves email ownership in email flow, OAuth provider verifies in SSO flow)

## Environment Variables

### `LOOMIO_SSO_FORCE_USER_ATTRS`

If enabled, every OAuth/SAML sign-in overwrites the Loomio user's name and email with values from the SSO provider.

**Default:** Not set (user attributes are only set on account creation)
**Use case:** When SSO is the source of truth for user attributes

**Implementation:** Logic is in `IdentityService.link_or_create` - syncs attributes after identity is linked/created

---

## Signup vs Signin Distinction

The distinction between "signup" and "signin" is based on email state in the users table:

**Signin:** Email exists in users table (verified or unverified)
- User can authenticate with existing code/password flow
- Email verification is skipped (they've already proven ownership)

**Signup:** Email does not exist in users table
- Send sign-in code to verify email ownership
- User creates account during first successful authentication
- User can optionally set password after authentication

**Unverified Account (from invitation):** Email exists but `email_verified = false`
- Treated as signup flow
- Invitation sender already proved this is a real email address
- Upon successful authentication with code, email becomes verified

This unified approach simplifies the UX: users always see a consistent flow regardless of account state.

---

## Account Linking Rules

### One OAuth Identity Per Provider
- A user can have at most one identity of each provider type
- Example: One Google account, one SAML account (different SAML instance = different provider)
- Multiple identities across different providers are supported (user can link Google + SAML + OAuth)

### Email-Based Account Detection
- When an OAuth identity is encountered, system searches for user by email
- If user exists (verified or unverified): Account is linked
- Enables automatic account linking for users who signed up via email first

### Silent Account Switches
- If user is not signed in and OAuth identity is linked to existing account: Sign in silently
- Expected behavior when user has multiple accounts and logs in with the account they intended

### Intentional Account Linking
- If user is signed in and initiates OAuth with different identity: Create pending identity
- User can then intentionally link the new identity or create new account
- Prevents accidental linking when users forget to logout

---

## Pending Identities

A pending identity is an OAuth/SAML identity not linked to any user. Created when:
- User is already signed in and attempts to authenticate with a new OAuth/SAML identity
- Prevents accidental account linking when users forget to logout before switching SSO accounts

**Detected by:** `if !identity.user` (check if identity has no linked user)

**User sees:** `identity_form.vue` with options:
1. Create new account with this identity
2. Sign in to existing account (creates login link via email)

Once user completes either action, pending identity is automatically linked to their account via `identity_form.vue` callback.

---

## Security Considerations

### UID as Source of Truth
- OAuth `uid` is immutable and globally unique per provider
- Used to identify returning users
- Email addresses can change; `uid` cannot

### Email as Linking Mechanism
- Used to find existing accounts for new OAuth identities
- Allows transparent account linking without additional signup steps
- Works because Loomio requires verified email addresses in normal use

### Prevention of Accidental Linking
- Users who forget to logout cannot accidentally link different SSO accounts to their existing account
- Required explicit action via identity_form.vue for intentional linking

### No Brute Force Protection on Email Lookup
- System checks if user exists by email during OAuth callback
- Does not leak existence of accounts (user doesn't see different error message)
- Not exploitable because email is public in most contexts

---

## Implementation Notes

### Database: omniauth_identities Table

```
user_id          (FK to users) - null if pending
identity_type    (string) - provider: 'oauth', 'google', 'saml', 'nextcloud', etc.
uid              (string) - immutable provider identifier
email            (string) - may differ from linked user's email
name             (string) - display name from provider
access_token     (string) - for API access to provider
logo             (string) - avatar URL from provider
custom_fields    (jsonb) - provider-specific data

Unique constraint: (identity_type, uid)
```

### Architecture

**IdentityService** (`app/services/identity_service.rb`)
- Core account linking logic: `IdentityService.link_or_create(identity_params:, current_user:)`
- Handles all SSO providers uniformly
- Returns Identity object (caller checks `identity.user` to detect pending)
- Inlines user attribute sync logic (when `LOOMIO_SSO_FORCE_USER_ATTRS` enabled)

**Controllers** (OAuth, SAML, etc.)
- Provider-specific validation (OAuth token exchange, SAML response validation)
- Call `IdentityService.link_or_create` with extracted identity params
- Handle pending identity flow (show identity_form.vue)
- Sign in user and set flash messages

**Related Models**

- **User Model** (`app/models/user.rb`)
  - `has_many :identities`
  - `email_verified` attribute

- **Identity Model** (`app/models/identity.rb`)
  - `belongs_to :user, optional: true`

- **Sessions Controller** (`app/controllers/api/v1/sessions_controller.rb`)
  - Email/password sign-in logic
  - Session management

- **Identity Controllers** (`app/controllers/identities/`)
  - `base_controller.rb` - OAuth callback handling (subclassed by google, oauth, nextcloud)
  - `saml_controller.rb` - SAML callback handling

---

## Cleanup of Orphaned Identities

Pending identities that are not linked to any user (failed account linking attempts) are automatically deleted after 7 days via the hourly maintenance task.

**Implementation:** The `loomio:hourly_tasks` rake task calls `Identity.stale(days: 7).delete_all`

**Scope:** Defined in Identity model with `scope :stale, ->(days: 7) { pending.where('created_at < ?', days.days.ago) }`

---

## Future Enhancements

1. **Account merging** - Separate flow for intentionally merging two complete accounts (currently exists in `MergeUsersService`)
2. **Username syncing** - Consider syncing username from provider if it's authoritative (mentioned in issue but requires careful handling for @mentions and permalinks)
3. **Per-provider configuration** - Make `LOOMIO_SSO_FORCE_USER_ATTRS` configurable per provider instead of global
