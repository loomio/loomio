# Tags improvements

Tags have been updated to work more consistently across an organization, including parent groups and subgroups. The changes make tags easier to apply, easier to filter by, and clearer to manage.

## Organization-wide tags

Tags now belong to the organization rather than being managed separately inside each subgroup. A tag such as `Planning` is treated as the same tag across the parent group and its subgroups, so it can be used to group related threads and polls across the organization.

Subgroups still matter when choosing which tags to show. Loomio keeps track of which groups are currently using each tag, so tag selectors can show tags that are local to the current group by default, with an option to see all tags in the organization.

Tags are also stored and displayed in alphabetical order. When tags are added to a thread or poll, they are sorted so the order is predictable everywhere they appear.

## Permissions

People who can edit a thread or poll can apply and remove tags on it.

Groups now have a Members can create tags permission. It is enabled by default. When enabled, members who can tag a thread or poll can also create a new tag while tagging it. When disabled, members can still apply existing tags, but cannot introduce new tag names.

Subgroup admins can apply existing tags and create new tags while tagging content in their subgroup.

Only parent group admins can curate the organization tag list. Curating includes renaming tags, deleting tags, and changing tag colours. When a parent group admin renames or deletes a tag, the change applies across the whole organization, including topics the admin may not individually see.

## Selecting tags

The tag selector now saves immediately. There is no separate Save button: selecting or clearing a tag updates the thread or poll straight away.

The selector shows tags used in the current group first. Use Show more to see all tags in the organization, then Show fewer to return to tags used in the current group.

New tag creation is available inside the selector for people who are allowed to create tags. The new tag control now has a tag-plus icon, and submitting an empty new-tag field closes the field without creating anything.

## Filtering by tags

The Discussions and Polls panels now use the same tag filter menu. The menu includes a filter textbox at the top, so large tag lists can be searched quickly.

When a tag filter is active, the panel shows the selected tag in the filter button instead of opening a separate tag panel. Parent group admins also get an Edit tags option from this menu, which opens the organization tag editor.

If a group has threads but the current filters find none, the Discussions panel now says:

`No threads found that match your filters`

This replaces the old new-group welcome message in filtered empty states.

## Visual changes

Tag colours are now shown as small colour dots next to tag names, rather than filling the whole tag chip or list item. This keeps the interface calmer and avoids contrast problems with dark or intense tag colours.
