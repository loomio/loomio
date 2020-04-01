## 2020-03-16 (Loomio 2.1.3)

- Add subscription information panel in Group Settings
- Add support for Loom (video platform) share and embed links in text editor
- Add sorting of Pinned Threads alphanumerically
- Add in-app notification for Group invitation
- Fix Meeting Poll vote form reset issue
- Fix Group page tabs and Thread action tabs not being scrollable on mobile
- Fix reopen Thread action not showing
- Fix sign-in modal showing when user is already signed in in some situations
- Fix completion link in merge accounts email

## 2020-02-26 (Loomio 2.1.2)

- Added ability for users to merge their own accounts together
- Added Emoji compatibility for Linux and older Windows
- Added basic subscription information to Group Settings
- Upgraded Vuetify
- Refactored email templates to not use instance variables
- Fix signing into Loomio via Slack when email already exists
- Fix styling of mentions

## 2020-02-17 (Loomio 2.1.1)

- Add coverage of more iterations of Youtube URLs for video embed in text editor
- Add distinction between Group URL and Group Invitation Link in Share modal, under Members tab
- Alphabetize list of Slack channels in Install Slack modal
- Remove list of groups from Install Slack modal
- Increase Dashboard timeframe for "Older" filter, from 6 months to 12 months
- Fix autofocus when replying in thread
- Fix displaying user's notification settings
- Fix handle suggestion on new group form
- Fix download link for CSV in group HTML export template
- Fix download link for CSV in poll HTML export template

## 2020-02-10 (Loomio 2.1.0)
- Major improvements to text editor: added Markdown support, previewing, collapsible menu:
![new_text_editor](https://user-images.githubusercontent.com/10443269/74111288-73809280-4bf8-11ea-858b-1123226a05a3.gif)
- Add ability to move comments and polls to a new thread
- Add group stats page, accessible from Settings panel
- Add documentation for setting up MS Azure Active Directory single sign-on
- Fix group data export
- Fix membership requests not displaying
- Fix a couple with issues with SAML

## 2020-01-31 (Loomio 2.0.2)
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
