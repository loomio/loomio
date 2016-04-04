describe 'Email settings', ->
  page = require './helpers/page_helper.coffee'

  beforeEach ->
    page.loadPath('setup_group')
    page.click '.navbar-user-options',
               '.navbar-user-options__email-settings-link'

  describe 'updating email settings', ->
    it 'lets you update email settings', ->
      page.click '.email-settings-page__daily-summary',
                 '.email-settings-page__update-button'
      page.expectFlash 'Email settings updated'

    it 'lets you set default email settings for all new memberships', ->
      page.click '.email-settings-page__change-default-link'
      page.expectText '.change-volume-form__title', 'Email settings for new groups'
      page.click '#volume-normal',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed about new threads and proposals in new groups.'
      page.expectText  '.email-settings-page__default-description', 'When you join a new group, you will be emailed about new threads and proposals.'

    it 'lets you update email settings for all current memberships', ->
      page.click '.email-settings-page__change-default-link',
                 '#volume-normal',
                 '.change-volume-form__apply-to-all',
                 '.change-volume-form__submit'
      page.expectText '.email-settings-page__membership-volume', 'Important activity'
