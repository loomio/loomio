## November 22nd - November 31st 2019
 - Loomio v2 client set as the default client
 - Show off version number!
 - Fix missing score poll translation
 - Handle access denied on group panels
 - Fix Install Slack form
 - Allow user to choose nesting level (and order?) of thread
 - Fix display/preview of attachments
 - Don't limit number of responses shown in poll email
 - Fix profile photo upload
 - Fix Proposal form not resetting after save
 - Fix Proposal form submitting stale data
 - Improve delayed jobs performance via Sidekiq

## December 1st - December 31st 2019
 - Fix attachments not showing up in Files panel
 - Remove ability to mute thread from thread preview
 - Fix Outcome not updating after successful edit
 - Fix Notification links
 - Fix User page not rendering HTML in bio properly
 - Allow pinning nested thread items
 - Add soft delete for Discussions before full deletion happens as a job
 - Add feature for self-service Group handle
 - Simplify submission flow abstraction
 - Fix Thread Nav to show pinned nested events
 - Fix Poll closing date not resetting after submission
 - Clean up vote forms for various Poll types for consistency
 - Show vote reason in Poll email
 - Fix showing errors on vote form
 - Fix Install Slack form again
 - Allow Safari 11

## January 1st - January 31st 2020
  - Fix Contact form
  - Fix Group data export
  - Fix Group form not showing validation errors for handle
  - Hide handle field in Group form if parent has no handle
  - Add support for SAML for individual groups
  - SAML provider fine-tuning
  - Add expiration date to memberships if there is a SAML provider
  - Thread Nav supports touch events
  - Upgrade Vue lib
  - Add polyfill for Object.entries
  - Add server-side-rendered (SSR) pages for Discussion and Group pages
  - More polyfills
  - More improvements to SSR pages
  - Use SSR content as loading placeholder
  - Fix for Slack channels not showing up in Install Slack form
  - Remove Poll unsubscribe link
  - Fix Poll export
  - For Proposals, users are not allowed to add/remove/edit options
  - Add SSR page for Explore
  - Fix starting Discussion from link
  - Use Babel for polyfills, cautiously
  
