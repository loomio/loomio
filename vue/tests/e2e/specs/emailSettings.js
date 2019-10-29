require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'lets_you_update_email_settings_while_logged_in': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--email-settings')
    testUpdate(page)
  },

  'lets_you_update_email_settings_while_logged_out': (test) => {
    page = pageHelper(test)

    page.loadPath('email_settings_as_restricted_user')
    testUpdate(page)
  },

  'update_the_email_settings_as_a_restricted_user': (test) => {
    page = pageHelper(test)

    page.loadPath('email_settings_as_restricted_user')
    testUpdate(page)
  }
}

testUpdate = (page) => {
  page.click('.email-settings-page__daily-summary label')
  page.click('.email-settings-page__update-button')
  page.expectFlash('Email settings updated')
}
