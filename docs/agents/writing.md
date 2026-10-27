# Writing and Markdown instructions

## Writing voice for user-facing content

These notes apply to any copy written for end users: UI strings, flash/error messages, changelog entries, emails, onboarding text, etc.

### Avoid

- **Unearned assumptions about the reader.** Don't presuppose how the user feels about a topic to set up a punchline or hook. We don't know how the reader feels, and for Loomio's cooperativist/organizer audience the assumption is often wrong. It can also read as belittling.
- **Virtue signaling.** Don't make moral claims about our own character ("run by humans, not growth metrics", "open, forever"). State the verifiable fact instead (worker-owned cooperative, open source) and let the reader draw their own conclusion.
- **Snazzy filler.** Emoji flourishes, wordplay, performed enthusiasm, exclamation marks on routine success messages — these read as marketing voice rather than a person's voice, and date badly.
- **Vague self-praise.** Don't reach for tone to earn trust ("out in the open", "small and scrappy"). Reach for facts instead.

### Prefer

Use **group admin** and **thread admin** for permission roles. **Administrator** is acceptable in longer prose. Do not use **coordinator** for either role, even when an older code identifier or source document uses it.

Plain, factual statements: what happened, what the software does, who it's for. No adjectives doing the work that a fact could do. This is consistent with the [localization guidance](localization.md) (calm tone, no exclamation marks on success messages).

- **Lead with the value to the user.** Explain what a feature helps people do before describing eligibility, configuration, or implementation constraints.
- **Do not mention email verification unless it is part of the workflow being explained.** In user-facing copy, say “people” or “users” rather than “people with a verified email address” when verification is only an insignificant implementation precondition.

## User-manual prose

Write for people trying to use the feature. Explain the useful steps and consequences that affect their decisions. Keep the prose concise and practical.

- Trust clear UI labels and screenshots. Do not narrate the interface, describe control order, or restate behaviour the reader can already see.
- Use simple, concrete examples chosen to demonstrate a meaningful difference. Prefer small, easy-to-follow numbers, such as vote weights of `0`, `1`, and `2`.
- Match the terminology used in the UI and reuse it consistently.
- Omit redundant reassurances, descriptions of absent settings, and development history. Include edge cases only when readers are likely to encounter them or need to act on them.
- Remove any sentence that does not help the reader understand or do something. Link to the relevant topic instead of repeating its explanation.

## Markdown formatting

- Do not hard-wrap prose in Markdown documents. Keep each paragraph and list item on one source line so the files remain easy to edit and render naturally on GitHub. Keep deliberate line breaks only where Markdown syntax or the content requires them, such as code blocks.
