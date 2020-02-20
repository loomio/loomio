require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'successfully_updates_a_profile': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--profile')

    page.fillIn('.profile-page__name-input input', 'Ferris Bueller')
    page.fillIn('.profile-page__username-input input', 'ferrisbueller')
    page.click('.profile-page__update-button')

    page.ensureSidebar()
    page.expectText('.sidebar__user-dropdown .v-list-item__title', 'Patrick SwayzeFerris Bueller')
  },

  'displays_a_user_and_their_non-secret_groups': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.goTo('u/jennifergrey')
    page.expectText('.user-page__content', 'Jennifer Grey')
    page.expectText('.user-page__content', '@jennifergrey')
    page.expectText('.user-page__groups', 'Dirty Dancing Shoes')
  },

  'displays_secret_groups_to_other_members': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_profile_with_group_visible_to_members')
    page.expectText('.user-page__groups', 'Secret Dirty Dancing Shoes')
  },

  'does_not_display_secret_groups_to_visitors': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_restricted_profile')
    page.expectNoText('.user-page__groups', 'Secret Dirty Dancing Shoes')
  },

  'allows_you_to_contact_other_users': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.goTo('u/jennifergrey')
    page.click('.user-page__contact-user')
    page.fillIn('.contact-request-form__message textarea', 'Here is a request to connect!')
    page.click('.contact-request-form__submit')
    page.expectNoElement('.flash-root__loading', 1000)
    page.expectFlash('Email sent to Jennifer Grey')

    page.goTo('u/patrickswayze')
    page.expectElement('.user-page')
    page.expectNoElement('.user-page__contact-user')
  },

  'does_not_accept_short_passwords': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.pause()
    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.user-page__change_password')
    page.fillIn('.change-password-form__password input', 'Smush')
    page.fillIn('.change-password-form__password-confirmation input', 'Smush')
    page.click('.change-password-form__submit')
    page.expectText('.change-password-form__password-container .lmo-validation-error__message', "is too short")
  },

  'does_not_accept_mismatched_passwords': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.pause()
    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.user-page__change_password')
    page.fillIn('.change-password-form__password input', 'SmushDemBerries')
    page.fillIn('.change-password-form__password-confirmation input', 'SmishDemBorries')
    page.click('.change-password-form__submit')
    page.expectText('.change-password-form__password-confirmation-container .lmo-validation-error__message', "doesn't match")
  },

  'can_set_a_password': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.pause()
    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.user-page__change_password')
    page.fillIn('.change-password-form__password input', 'SmushDemBerries')
    page.fillIn('.change-password-form__password-confirmation input', 'SmushDemBerries')
    page.click('.change-password-form__submit')
    page.expectFlash('Your password has been updated')
  },

  'successfully_deactivates_the_account': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')
    page.pause(300)
    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.user-page__deactivate_user')
    page.click('.confirm-modal__submit')
    page.expectText('.auth-modal', 'Sign into Loomio')
  },

  'deletes_the_account': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')
    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.user-page__delete_user')
    page.click('.confirm-modal__submit')
    page.expectText('.auth-modal', 'Sign into Loomio', 12000)
  },

  'merges_accounts': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_group')
    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--profile')
    page.clear('.profile-page__email-input input')
    page.fillIn('.profile-page__email-input input', 'jennifer_grey@example.com')
    page.expectElement('.profile-page__email-taken')
    page.click('.email-taken-find-out-more')
    page.click('.confirm-modal__submit')
    page.expectFlash('Verification email sent!')
    page.loadLastEmail()
    page.click('.base-mailer__button')
    page.pause()
    page.click('.btn--accent--raised')
    page.expectText('.header', "Merge successful!")
  }

}
