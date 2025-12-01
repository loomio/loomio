# Web Push Notifications - Deployment Notes

## Environment Variables Required

Add these to your deployment configuration (loomio-deploy repo):

```bash
# Generate VAPID keys in Rails console:
# vapid_key = WebPush.generate_key
# puts "VAPID_PUBLIC_KEY=#{vapid_key.public_key}"
# puts "VAPID_PRIVATE_KEY=#{vapid_key.private_key}"

VAPID_PUBLIC_KEY=your_generated_public_key_here
VAPID_PRIVATE_KEY=your_generated_private_key_here
REPLY_HOSTNAME=your_loomio_domain.com
```

## Database Migration

Run migrations to add push_volume fields and web_push_subscriptions table:

```bash
bin/rails db:migrate
```

## Gem Dependencies

The `web-push` gem (note: hyphenated, not `webpush`) has been added to support OpenSSL 3.0+

## Upgrade Notes

### Breaking Changes
- The `volume` field has been renamed to `email_volume` on:
  - `memberships`
  - `discussion_readers`
  - `stances`
  - `users.default_membership_volume` → `default_membership_email_volume`

### New Features
- Users can now independently control email and push notification volumes
- Web push notifications for: mentions, comments, discussions, polls, and outcomes
- New API endpoints:
  - `POST /api/v1/web_push_subscriptions` - Register push subscription
  - `DELETE /api/v1/web_push_subscriptions` - Unregister push subscription

### Frontend Changes Needed
- Update all references from `volume` to `email_volume` in Vue components
- Add UI for `push_volume` settings
- Implement service worker for web push
- Request notification permission from users
- Subscribe to push notifications and send subscription to API

## Testing VAPID Key Generation

In Rails console:
```ruby
vapid_key = WebPush.generate_key
puts "Public Key: #{vapid_key.public_key}"
puts "Private Key: #{vapid_key.private_key}"
```

## Security Notes

- VAPID keys should be generated once and kept consistent across deployments
- Store VAPID_PRIVATE_KEY securely (do not commit to version control)
- VAPID_PUBLIC_KEY can be public (will be shared with browser clients)

## iOS Specific Requirements

**IMPORTANT**: Web push notifications on iOS only work for PWAs (Progressive Web Apps) that have been:
1. Added to the home screen via "Add to Home Screen"
2. Opened at least once from the home screen icon

### User Communication Strategy
- Add in-app prompts encouraging iOS users to install the PWA
- Show banner/modal explaining the installation process for iOS users
- Provide step-by-step instructions:
  1. Tap the Share button in Safari
  2. Select "Add to Home Screen"
  3. Tap "Add" to confirm
  4. Open Loomio from the home screen icon (not from Safari)
  5. Enable push notifications when prompted

### Detection
You can detect iOS users who haven't installed the PWA:
```javascript
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
const isInStandaloneMode = window.matchMedia('(display-mode: standalone)').matches;
const needsPWAPrompt = isIOS && !isInStandaloneMode;
```

### UI Recommendations
- Add a persistent banner or notification for iOS users browsing via Safari
- Include visual instructions (screenshots) in the prompt
- Don't show push notification permission prompt until PWA is installed
- Consider email/in-app campaigns explaining iOS requirements
