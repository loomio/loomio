pageHelper = require './page_helper.coffee'

module.exports = (test) ->
  signInViaPassword: (email, password) ->
    page = pageHelper(test)
    page.fillIn '.auth-email-form__email input', email
    page.click '.auth-email-form__submit'
    page.fillIn '.auth-signin-form__password input', password
    page.click '.auth-signin-form__submit'

  signInViaEmail: (email) ->
    page = pageHelper(test)
    page.fillIn '.auth-email-form__email input', 'new@account.com'
    page.click '.auth-email-form__submit', '.auth-form input'
    page.fillIn '.auth-form input', 'New Account'
    page.click '.auth-signup-form__submit', '.auth-complete'
    page.loadPath 'use_last_login_token', '.auth-signin-form'
    page.click '.auth-signin-form__submit'
