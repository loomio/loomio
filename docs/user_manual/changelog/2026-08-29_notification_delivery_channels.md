# Consistent notification delivery channels

In-app notifications now use one authoritative set of recipients. Email and push delivery both start from those recipients and apply each recipient's channel volume for the relevant thread, group, or account default. A notification cannot add email or push recipients who do not receive the in-app notification.

Notifications with external delivery now treat email and push consistently. Mentions and other directed notifications apply both channel volumes from the same thread, group, or account context. In-app-only notices, including reactions, invitation acceptances, membership-request approvals, coordinator changes, and unknown-sender notices, send neither email nor push. The legacy account settings for mention emails and proposal-closing emails have been removed; the Email and Push volume settings now control those deliveries.

Explicit invitation resends remain email-only because resending an invitation is a direct email action rather than an activity notification.
