# Group handle redirects

Group links are now more resilient when a group changes its handle.

## What changed

When a group handle changes, links that use the old handle redirect people to the current group address.

For example, if a group changes from:

`/old-handle`

to:

`/new-handle`

people who use the old link are permanently redirected to the new one. The redirect preserves any query parameters and applies the group's usual visibility permissions.

## Why this matters

This helps preserve links shared in emails, documents, chat tools, bookmarks, and older Loomio notifications.

It also reduces disruption when an organization renames a group or updates handles to match a new naming convention.

## Limits

Loomio keeps up to three old handles. These handles are protected so they cannot be reused for another group. If the handle changes more than three times, the oldest handle expires and its links no longer redirect.

Email sent to an address that uses one of the three retained handles continues to reach the group, so replies to older notifications still work. When an old handle expires, its email address no longer reaches the group.
