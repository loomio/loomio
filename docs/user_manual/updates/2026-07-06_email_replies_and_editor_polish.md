# Email replies and editor polish

Email reply handling and editor behavior were improved.

## Long email replies

When someone replies by email with a message that is too long, Loomio now handles the rejection more clearly.

Instead of failing silently, Loomio sends a rejection email explaining that the comment could not be posted because it exceeded the allowed length.

## Text-only forwarded emails

Forwarded text-only inbound messages are handled more reliably, avoiding blank forwarded email content in cases where no HTML body is present.

## Draft discard behavior

Discarding formatted text drafts now uses the editor undo flow more consistently.

This helps forms clear draft content without leaving stale rich-text state behind.

## Contact form behavior

After a successful contact form submission, Loomio now shows a success flash and resets the form instead of hiding it.

This gives clearer feedback while keeping the form available.

## Copy link fix

Copy link actions now include the full domain where expected, so copied links work correctly outside the current browser context.
