# Group handle redirects

Group links are now more resilient when a group changes its handle.

## What changed

When a group handle changes, Loomio remembers the old handle and redirects people to the current group address.

For example, if a group changes from:

`/g/old-handle`

to:

`/g/new-handle`

people who use the old link are sent to the new one.

## Why this matters

This helps preserve links shared in emails, documents, chat tools, bookmarks, and older Loomio notifications.

It also reduces disruption when an organization renames a group or updates handles to match a new naming convention.

## Limits

Old handles are protected so they cannot be reused in ways that would send people to the wrong group.

Email replies and inbound messages also understand redirected group handles, so older notification emails keep working after a handle change.
