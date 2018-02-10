// require('coffeescript/register')
// pageHelper = require('../helpers/page_helper.coffee')
//
// module.exports = {
//   'successfully updates a profile': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_discussion', '.user-dropdown__dropdown-button')
//     page.click('.user-dropdown__dropdown-button', '.user-dropdown__list-item-button--profile')
//     page.click('.user-dropdown__list-item-button--profile', '.profile-page'
//     profileHelper.updateProfile('Ferris Bueller', 'ferrisbueller', 'ferris@loomio.org')
//     expect(profileHelper.nameInput().getAttribute('value')).toContain('Ferris Bueller')
//     expect(profileHelper.usernameInput().getAttribute('value')).toContain('ferrisbueller')
//     expect(profileHelper.emailInput().getAttribute('value')).toContain('ferris@loomio.org')
//   },
//
//   'displays a user and their non-secret groups': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_discussion', '.thread-page')
//     page.goTo('u/jennifergrey', '.user-page__content')
//     page.expectText('.user-page__content', 'Jennifer Grey')
//     page.expectText('.user-page__content', '@jennifergrey')
//     page.expectText('.user-page__groups', 'Dirty Dancing Shoes')
//   },
//
//   'displays secret groups to other members': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_profile_with_group_visible_to_members', '.user-page__profile')
//     page.expectText('.user-page__profile', 'Secret Dirty Dancing Shoes')
//   },
//
//   'does not display secret groups to visitors': (test) => {
//     page = pageHelper(test)
//
//     page.loadPath('setup_restricted_profile', '.user-page__profile')
//     page.expectNoText('.user-page__profile', 'Secret Dirty Dancing Shoes')
//   },
//
//   'allows you to contact other users': (test) => {
//     page = pageHelper(test)
//
//     page.goTot('u/jennifergrey', '.user-page__contact-user')
//     page.click('.user-page__contact-user', '.contact-request-form__message')
//     page.fillIn('.contact-request-form__message', 'Here is a request to connect!')
//     page.click('.contact-request-form__submit', '.flash-root__message')
//     page.expectText('.flash-root__message', 'Email sent to Jennifer Grey')
//
//     page.goTo('u/patrickswayze', '.user-page')
//     page.expectNoElement('.user-page__contact-user')
//   },
//
//   'can set a password': (test) => {
//     page = pageHelper(test)
//
//     page.click('.user-dropdown__dropdown-button', '.user-dropdown__list-item-button--profile')
//     page.click('.user-dropdown__list-item-button--profile', '.profile-page__change-password')
//     page.click('.profile-page__change-password')
//     page.fillIn('.change-password-form__password', 'Smush')
//     page.fillIn('.change-password-form__password-confirmation', 'Smush')
//     page.click('.change-password-form__submit')
//     page.sleep(500))
//     page.expectText('.change-password-form', "is too short")
//
//     page.fillIn('.change-password-form__password', 'SmushDemBerries')
//     page.fillIn('.change-password-form__password-confirmation', 'SmishDemBorries')
//     page.click('.change-password-form__submit')
//     page.sleep(500))
//     page.expectText('.change-password-form', "doesn't match")
//
//     page.fillIn('.change-password-form__password', 'SmushDemBerries')
//     page.fillIn('.change-password-form__password-confirmation', 'SmushDemBerries')
//     page.click('.change-password-form__submit')
//     page.expectFlash('Your password has been updated')
//   },
//
//     describe 'deactivating an account', ->
//
//       describe 'as the sole coordinator of a group', ->
//         xit 'successfully deactivates the account', ->
//           page.click '.user-dropdown__dropdown-button'
//           page.click '.user-dropdown__list-item-button--profile'
//           page.click '.profile-page__deactivate'
//           page.expectText '.deactivation-modal', 'When you deactivate your account:'
//           page.click '.deactivation-modal__confirm'
//           browser.driver.sleep(100)
//           page.expectText '.only-coordinator-modal', 'A group must have at least one coordinator. You are the only coordinator of the following groups:'
//
//       describe 'as one of several coordinators of a group', ->
//         xit 'prevents you from deactivating the account', ->
//           page.loadPath 'setup_group_with_multiple_coordinators'
//           page.click '.user-dropdown__dropdown-button'
//           page.click '.user-dropdown__list-item-button--profile'
//           page.click '.profile-page__deactivate'
//           page.click '.deactivation-modal__confirm'
//           page.click '.deactivate-user-form__submit'
//           page.expectText '.auth-modal', 'Sign into Loomio'
//
// }
