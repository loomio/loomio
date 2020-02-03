## 2020-01-31
- Add support for SAML for individual groups
- Add server side rendered pages for groups, threads and explore
- Add polyfills for old browsers
- Thread Nav supports touch events
- Upgrade Vue lib
- Remove Poll unsubscribe link
- Use Babel for polyfills, cautiously
- Fix Proposals, users are not allowed to add/remove/edit options
- Fix for Slack channels not showing up in Install Slack form
- Fix starting Discussion from link
- Fix Poll export
- Fix Contact form
- Fix Group data export
- Fix Group form not showing validation errors for handle

## 2019-12-31
- Add feature for self-service Group handle
- Remove ability to mute thread from thread preview
- Allow pinning nested thread items
- Add soft delete for Discussions before full deletion happens as a job
- Clean up vote forms for various Poll types for consistency
- Show vote reason in Poll email
- Allow Safari 11
- Fix attachments not showing up in Files panel
- Fix Outcome not updating after successful edit
- Fix Notification links
- Fix User page not rendering HTML in bio properly
- Fix Thread Nav to show pinned nested events
- Fix Poll closing date not resetting after submission
- Fix showing errors on vote form
- Fix Install Slack form again

## 2019-11-31
- Loomio v2 client set as the default client
- Allow user to choose display order and nesting of thread
- Add sidekiq and replace delayed job
- Show off version number!
- Don't limit number of responses shown in poll email
- Fix missing score poll translation
- fix Handle access denied on group panels
- Fix Install Slack form
- Fix profile photo upload
- Fix Proposal form not resetting after save
- Fix Proposal form submitting stale data
- Fix display/preview of attachments
