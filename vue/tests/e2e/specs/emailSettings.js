pageHelper = require('../helpers/pageHelper')

module.exports = {
  'lets_you_update_email_settings_while_logged_in': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--email-settings')
    page.expectElement('.email-settings-page__deactivate-card')
    testUpdate(page)
  },

  'lets_you_update_email_settings_while_logged_out': (test) => {
    page = pageHelper(test)

    page.loadPath('email_settings_as_restricted_user')
    page.expectNoElement('.email-settings-page__deactivate-card')
    testUpdate(page)
  },

  'update_the_email_settings_as_a_restricted_user': (test) => {
    page = pageHelper(test)

    page.loadPath('email_settings_as_restricted_user')
    page.expectNoElement('.email-settings-page__deactivate-card')
    testUpdate(page)
  },

  'hides_push_group_settings_without_a_registered_device': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_manual_oatmilk_email_settings')
    page.waitFor('.email-settings-page__push-status-loaded')
    page.expectNoElement('.email-settings-page__push-column')
    page.expectNoText('.email-settings-page__group-notifications-card', 'email and push')
  }
}

testUpdate = (page) => {
  page.click('.email-settings-page__digest-card .v-select .v-field')
  page.waitFor('.v-overlay--active .v-list')
  page.execute("Array.from(document.querySelectorAll('.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Monday')).click()")
  page.click('.email-settings-page__update-button')
  page.expectFlash('Email settings updated')
}
