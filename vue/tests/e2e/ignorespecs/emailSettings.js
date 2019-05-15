require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'lets_you_update_email_settings_while_logged_in': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.user-dropdown__dropdown-button')
    page.click('.user-dropdown__list-item-button--email-settings')
    testUpdate(page)
  },

  'lets_you_set_default_email_settings_for_all_new_memberships_while_logged_in': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.user-dropdown__dropdown-button')
    page.click('.user-dropdown__list-item-button--email-settings')
    testDefaultUpdate(page)
  },

  'lets_you_update_email_settings_for_all_current_memberships_while_logged_in': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.user-dropdown__dropdown-button')
    page.click('.user-dropdown__list-item-button--email-settings')
    testMembershipUpdate(page)
  },

  'lets_you_update_email_settings_while_logged_out': (test) => {
    page = pageHelper(test)

    page.loadPath('email_settings_as_restricted_user')
    testUpdate(page)
  },

  'lets_you_set_default_email_settings_for_all_new_memberships_while_logged_out': (test) => {
    page = pageHelper(test)

    page.loadPath('email_settings_as_restricted_user')
    testDefaultUpdate(page)
  },

  'lets_you_update_email_settings_for_all_current_memberships_while_logged_out': (test) => {
    page = pageHelper(test)

    page.loadPath('email_settings_as_restricted_user')
    testMembershipUpdate(page)
  },

  'displays_the_email_settings_as_a_restricted_user': (test) => {
    page = pageHelper(test)

    page.loadPath('email_settings_as_logged_in_user')
    page.expectNoElement('.navbar__sign-in')
  }
}

testUpdate = (page) => {
  page.click('.email-settings-page__daily-summary label')
  page.click('.email-settings-page__update-button')
  page.expectText('.flash-root__message', 'Email settings updated')
}

testDefaultUpdate = (page) => {
  page.click('.email-settings-page__change-default-link')
  page.expectText('.change-volume-form__title', 'Email settings for new groups')
  page.click('.volume-loud')
  page.click('.change-volume-form__submit')
  page.expectText('.flash-root__message', 'You will be emailed all activity in new groups.')
  page.expectText('.email-settings-page__default-description', 'When you join a new group, you will be emailed whenever there is activity.')
}

testMembershipUpdate = (page) => {
  page.click('.email-settings-page__change-default-link')
  page.click('.volume-loud')
  page.click('.change-volume-form__apply-to-all label')
  page.click('.change-volume-form__submit')
  page.expectText('.flash-root__message', 'You will be emailed all activity in all your groups.')
  page.expectText('.email-settings-page__membership-volume', 'All activity')
}
