describe 'Email settings', ->
  page = require './helpers/page_helper.coffee'

  beforeEach ->
    page.loadPath('setup_group')

  describe 'updating email settings', ->
    it 'lets you update email settings', ->
      page.click '.navbar-user-options',
                 '.navbar-user-options__email-settings-link',
                 '.email-settings-page__daily-summary',
                 '.email-settings-page__update-button'
      page.expectFlash 'Email settings updated'

    it 'lets you set default email settings for all new memberships', ->
      page.click '.navbar-user-options',
                 '.navbar-user-options__email-settings-link'
      page.click '.email-settings-page__change-default-link'
      page.expectText '.change-volume-form__title', 'Email settings for new groups'
      page.click '#volume-normal',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed about new threads and proposals in new groups.'
