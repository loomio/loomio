pageHelper = require './page_helper'

module.exports = (test) ->
  signInViaPassword: (email, password) ->
    page = pageHelper(test)
    page.fillIn '.auth-email-form__email input', email
    page.click '.auth-email-form__submit'
    page.fillIn '.auth-signin-form__password input', password
    page.click '.auth-signin-form__submit'

  signInViaEmail: (email = "new@account.com") ->
    page = pageHelper(test)
    page.fillIn '.auth-email-form__email input', email
    page.click '.auth-email-form__submit'
    page.fillIn '.auth-signup-form input', 'New Account'
    page.click('.auth-signup-form__legal-accepted')
    page.click '.auth-signup-form__submit'
    page.expectElement '.auth-complete'
    page.loadPath 'use_last_login_token'
    page.click '.auth-signin-form__submit'

  signUpViaInvitation: (name = "New person") ->
    page = pageHelper(test)
    page.click '.auth-email-form__submit'
    page.fillIn '.auth-signup-form__name input', name
    page.click('.auth-signup-form__legal-accepted')
    page.click '.auth-signup-form__submit'
