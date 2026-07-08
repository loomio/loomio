# Performance and scale improvements

Several parts of Loomio were optimized for larger groups and busy organizations.

## Faster inbox and thread lists

Inbox topic queries were rewritten and indexed to load much faster, especially for accounts with many groups or a large history of threads.

Sidebar unread counts were also adjusted to focus on topics active within the last 6 weeks. This keeps counts faster and more relevant for day-to-day work.

## Faster thread views

Thread view queries were improved with additional indexes for event depth and pinned events.

This helps large or deeply nested threads load more predictably.

## Faster notifications and activity loading

Several notification and event-list paths were optimized to avoid repeated database lookups.

Areas improved include:

- notification lists
- event lists
- topic visibility checks
- comment loading
- reaction loading
- voter lists

## Faster mention search

Mention search was changed to look up topic members and admins more efficiently.

This is most noticeable in large groups or threads with many participants.

## Large report reliability

Participation report queries were optimized so larger reports can be generated more reliably.

For power users and admins, this means reporting across many groups, tags, or time periods should feel more practical.
