require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'successfully_updates_a_profile': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.user-dropdown__dropdown-button')
    page.click('.user-dropdown__list-item-button--profile')
    page.fillIn('.profile-page__name-input', 'Ferris Bueller')
    page.fillIn('.profile-page__username-input', 'ferrisbueller')
    page.click('.profile-page__update-button')
    page.pause()
    page.click('.user-dropdown__dropdown-button')
    page.expectText('.user-dropdown__user-details', 'Ferris Bueller')
    page.expectText('.user-dropdown__user-details', 'ferrisbueller')
  },

  'displays a user and their non-secret groups': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.goTo('u/jennifergrey')
    page.expectText('.user-page__content', 'Jennifer Grey')
    page.expectText('.user-page__content', '@jennifergrey')
    page.expectText('.user-page__groups', 'Dirty Dancing Shoes')
  },

  'displays secret groups to other members': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_profile_with_group_visible_to_members')
    page.expectText('.user-page__profile', 'Secret Dirty Dancing Shoes')
  },

  'does not display secret groups to visitors': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_restricted_profile')
    page.expectNoText('.user-page__profile', 'Secret Dirty Dancing Shoes')
  },

  'allows you to contact other users': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.goTo('u/jennifergrey')
    page.click('.user-page__contact-user')
    page.fillIn('.contact-request-form__message', 'Here is a request to connect!')
    page.click('.contact-request-form__submit')
    page.expectNoElement('.flash-root__loading', 1000)
    page.expectText('.flash-root__message', 'Email sent to Jennifer Grey')

    page.goTo('u/patrickswayze')
    page.expectElement('.user-page')
    page.expectNoElement('.user-page__contact-user')
  },

  'does not accept short passwords': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.user-dropdown__dropdown-button')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.profile-page__change-password')
    page.fillIn('.change-password-form__password', 'Smush')
    page.fillIn('.change-password-form__password-confirmation', 'Smush')
    page.click('.change-password-form__submit')
    page.expectText('.change-password-form__password-container .lmo-validation-error__message', "is too short", 8000)
  },

  'does not accept mismatched passwords': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.user-dropdown__dropdown-button')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.profile-page__change-password')
    page.fillIn('.change-password-form__password', 'SmushDemBerries')
    page.fillIn('.change-password-form__password-confirmation', 'SmishDemBorries')
    page.click('.change-password-form__submit')
    page.expectText('.change-password-form__password-confirmation-container .lmo-validation-error__message', "doesn't match", 8000)
  },

  'can set a password': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.user-dropdown__dropdown-button')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.profile-page__change-password')
    page.fillIn('.change-password-form__password', 'SmushDemBerries')
    page.fillIn('.change-password-form__password-confirmation', 'SmushDemBerries')
    page.click('.change-password-form__submit')
    page.expectText('.flash-root__message', 'Your password has been updated')
  },

  'successfully_deactivates_the_account': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')
    page.click('.user-dropdown__dropdown-button')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.profile-page__deactivate')
    page.click('.confirm-modal__submit')
    page.pause(2000)
    page.click('.confirm-modal__submit')
    page.expectText('.auth-modal', 'Sign into Loomio')
  },

  'deletes_the_account': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')
    page.click('.user-dropdown__dropdown-button')
    page.click('.user-dropdown__list-item-button--profile')
    page.click('.profile-page__delete')
    page.click('.confirm-modal__submit')
    page.expectText('.auth-modal', 'Sign into Loomio', 12000)
  }

}
