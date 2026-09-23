# Email templates

## Purpose

This document defines how Loomio email templates are structured, styled, tested, and reviewed. Email should remain readable in clients with limited CSS support, in light and dark color schemes, and when images are unavailable.

## Templates and components

Write new email views as Phlex components under `app/views`. Do not add ERB templates or separate plain-text templates; the plain-text version is generated from the HTML email.

Use `Views::ApplicationMailer::Component` for reusable fragments. Use `Views::NotificationMailer::Layout` for notification-style messages with no header logo, and render the small configured logo in the footer. Use `Views::ApplicationMailer::BaseLayout` only for account and authentication emails that deliberately use the large header logo.

Break messages into reusable content components rather than nesting complete email documents. A component embedded in another email must not render its own `doctype`, `html`, `head`, `body`, tracking pixels, unsubscribe links, or footer.

Notification-backed rendering must use `NotificationRenderingContext` and the notification's authorized `subject_model`. Map supported model types explicitly. Do not add a generic model serializer or reflection fallback that could expose fields from a new notification subject without review.

## Visual design

Email styling is deliberately minimal. The default body text is user-generated content and remains the primary reading size.

- User-generated content uses 16px text with a 24px line height.
- Notification metadata uses 14px text with a 20px line height.
- Author names, bylines, and other secondary metadata use 13px text with a 20px line height and reduced opacity.
- Headings follow the document hierarchy rather than choosing a level for its default size. Use one `h1` for the email title, then `h2` through `h6` for nested sections. Shared components that render a heading must let their caller choose the appropriate level. Email headings use the same 28px, 20px, and 16px scale as the client `formatted_text` component; `h3` through `h6` share the smallest size.
- Use `strong` for notification sentences, labels, and other emphasized text that does not introduce a document section. Do not use a heading solely to make text bold or large.
- Semantic `main`, `section`, and `article` elements are encouraged. Their display, margin, and padding are reset in the shared stylesheet so rendering does not depend on email-client defaults.
- Actor avatars are top-aligned with notification text. Notification content follows the text in the same adjacent column, so a short headline does not create an avatar-height gap before the content.

Do not set foreground or background colors for ordinary text containers. Light and dark mode should inherit the email client's colors. Reduced-emphasis text may use opacity because it works with inherited colors in either scheme. Buttons and poll graphics may use configured theme colors, with corresponding `prefers-color-scheme: dark` overrides in `EmailHelper#email_theme_css`.

Use `currentColor` for neutral borders. Preserve explicit colors that are part of user content or poll semantics, such as highlights, proposal options, and result bars.

## CSS and class names

Email CSS is loaded from `app/assets/stylesheets/email.css` and `EmailHelper#email_theme_css`. Rails inlines these rules into the delivered HTML. Do not load client or Vuetify stylesheets into email templates.

Use short names under the flat `email-` namespace. A class must control presentation or identify a genuinely ambiguous repeated structure that cannot be selected reliably by semantic HTML and text. Do not add classes solely as convenient test selectors.

Use purpose-named families for the email body and branding (`email-body`, `email-header-*`, `email-footer-*`), actions (`email-actions`, `email-button-*`), notification and thread content (`email-notification-*`, `email-thread-*`, `email-activity-*`, `email-user-content`, `email-meta`), attachments (`email-attachment-*`), and poll results (`email-poll-*`, `email-results-*`, `email-table-*`, `email-meeting-*`, `email-status-*`).

Do not use client-framework classes such as `v-table`, `v-layout-table`, Vuetify typography classes, or generic spacing and alignment utilities in email views. Do not retain old `base-mailer__`, `mailer__`, `user-mailer__`, `topic-mailer__`, `notification-mailer__`, or `poll-mailer__` names. Avoid generic classes such as `content`, `description`, `icon`, and `center`; put layout and spacing on a purpose-named `email-*` class instead.

Use semantic HTML for document structure. Use tables only where email rendering requires tabular data or robust columns, give those tables purpose-named `email-*` classes, and do not copy client-framework attributes or presentation roles into email markup.

Prefer percentage or automatic widths for content columns. Give avatar/icon columns an explicit pixel width and let the adjacent content column consume the remaining space. Do not combine fixed 50px and 550px columns inside a fixed 600px container.

## User-generated content

Render translated rich text through `TranslationService.formatted_text` inside an `email-user-content` container, and render attachments through `Views::NotificationMailer::Common::Attachments`. Do not wrap formatted HTML in an additional `p` element because the rendered content may already contain block elements.

The `email-user-content` rules mirror the client `formatted_text` component for paragraphs, headings, emphasis, alignment, lists, images, code, blockquotes, tables, highlights, and task lists. Keep those styles synchronized when formatted-text behavior changes. Replace interactive, theme-variable, mask-image, and hover behavior with static email-safe equivalents, and use `currentColor` rather than fixed neutral colors where light and dark modes need to inherit the client palette.

Discarded or inaccessible content must not be rendered from an old notification. Check current authorization before the email is constructed, and fail closed for unsupported subject types. Shared vote components must continue to enforce anonymous-poll and hidden-results rules.

## Links, acknowledgement, and unsubscribe controls

Use URL helpers and tracked URLs rather than string-building application links. Include recipient tokens only through the existing helper methods.

Every recurring or notification email must provide an unsubscribe or notification-preferences link in its footer. Use a descriptive action such as `Unsubscribe`; do not use link text such as `Click here`.

Opening an email must not acknowledge a catch-up or mark notifications as read. Explicit acknowledgement actions belong in visible buttons or links. Tracking pixels used by immediate notification emails must remain scoped to their existing notification/topic behavior.

## Testing

Test Loomio behavior and rendered outcomes rather than class names. Prefer, in order:

1. Semantic tags and attributes, such as `main`, `section`, `article`, correctly nested headings, `strong` notification text, links with a known `href`, image `alt` text, and button text.
2. Text content within a semantic region.
3. A styled `email-` class when repeated structures are genuinely ambiguous, such as selecting one notification from several.

Do not add an unstyled class to make a test easier. If a test needs to locate one element among repeated structures, first use its text, link destination, image alternative text, or relationship to a heading.

Mailer rendering tests should cover the content hierarchy, recipient-specific copy, authorization failures, anonymous/hidden poll behavior, discarded content, action URLs, unsubscribe links, and required branding. When shared notification components change, run the focused discussion and poll mailer suites as well as the catch-up mailer tests.

## Validation

Run focused Rails mailer and controller tests first. Parse changed locale files, run diagnostics, and run `git diff --check`. For user-manual email examples, regenerate one screenshot at a time with `bin/e2e-screenshots`, inspect it in light mode, rebuild the documentation with `bundle exec ruby docs/build.rb`, and obtain human approval before continuing to the next screenshot.
