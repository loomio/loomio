describe 'Email settings', ->
  page = require './helpers/page_helper.coffee'

  testUpdate = ->
    page.click '.email-settings-page__daily-summary',
               '.email-settings-page__update-button'
    page.expectFlash 'Email settings updated'

  testDefaultUpdate = ->
    page.click '.email-settings-page__change-default-link'
    page.expectText '.change-volume-form__title', 'Email settings for new groups'
    page.click '#volume-loud',
               '.change-volume-form__submit'
    page.expectFlash 'You will be emailed all activity in new groups.'
    page.expectText  '.email-settings-page__default-description', 'When you join a new group, you will be emailed whenever there is activity.'

  testMembershipUpdate = ->
    page.click '.email-settings-page__change-default-link',
               '#volume-loud',
               '.change-volume-form__apply-to-all',
               '.change-volume-form__submit'
    page.expectText '.email-settings-page__membership-volume', 'All activity'

  describe 'logged in', ->
    beforeEach ->
      page.loadPath('setup_group')
      page.click '.sidebar__list-item-button--email-settings'

    it 'lets you update email settings', testUpdate
    it 'lets you set default email settings for all new memberships', testDefaultUpdate
    it 'lets you update email settings for all current memberships', testMembershipUpdate

  describe 'logged out without unsubscribe token', ->
    it 'allows login to set email preferences', ->
      page.loadPath 'email_settings_as_visitor'
      page.fillIn '#user-email', 'patrick_swayze@example.com'
      page.fillIn '#user-password', 'gh0stmovie'
      page.click '.sign-in-form__submit-button'
      testUpdate()

  describe 'logged in with unsubscribe token', ->
    it 'displays you as logged in', ->
      page.loadPath 'email_settings_as_logged_in_user'
      page.expectElement '.sidebar__content'

  describe 'logged out', ->
    beforeEach ->
      page.loadPath 'email_settings_as_restricted_user'

    it 'lets you update email settings', testUpdate
    it 'lets you set default email settings for all new memberships', testDefaultUpdate
    it 'lets you update email settings for all current memberships', testMembershipUpdate
