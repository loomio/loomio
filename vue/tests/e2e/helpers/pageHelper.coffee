module.exports = (test) ->
  refresh: ->
    test.refresh()

  loadPath: (path, opts = {}) ->
    test.url "http://localhost:3000/dev/#{opts.controller || 'nightwatch'}/#{path}?vue=1"
    test.waitForElementVisible('main', 10000)

  goTo: (path) ->
    test.url "http://localhost:3000/#{path}"

  expectCount: (selector, count, wait) ->
    @waitFor(selector, wait)
    test.elements 'css selector', selector, (result) =>
      test.verify.equal(result.value.length, count)

  expectElement: (selector, wait) ->
    @waitFor(selector, wait)
    test.expect.element(selector).to.be.present

  expectElementNow: (selector) ->
    test.expect.element(selector).to.be.present

  expectNoElement: (selector, wait = 1000) ->
    test.expect.element(selector).to.not.be.present.after(wait)

  click: (selector, pause) ->
    @waitFor(selector)
    test.click(selector)
    test.pause(pause) if pause

  scrollTo: (selector, callback, wait) ->
    @waitFor(selector, wait)
    test.getLocationInView(selector, callback)

  ensureSidebar: ->
    @waitFor('.navbar__left')
    test.click('.navbar__sidenav-toggle')
    # test.elements 'css selector', '.sidenav-left', (result) =>
    #   if result.value.length == 0
    #     test.click('.navbar__sidenav-toggle')
    #     @waitFor('.sidenav-left')
    #   else
    #     console.log 'not there'

  pause: (time = 1000) ->
    test.pause(time)

  mouseOver: (selector, callback, wait) ->
    @waitFor(selector, wait)
    test.moveToElement(selector, 10, 10, callback)

  fillIn: (selector, value, wait) ->
    @waitFor(selector, wait)
    test.clearValue(selector)
    test.setValue(selector, value)

  execute: (script) ->
    test.execute(script)

  selectFromAutocomplete: (selector, value) ->
    @fillIn(selector, value)
    @click(selector)
    @pause()
    @execute("document.querySelector('.md-autocomplete-suggestions li').click()")

  selectOption: (selector, option) ->
    # TODO
    # @click selector
    # element(By.cssContainingText('md-option', option)).click()

  expectValue: (selector, value, wait) ->
    @waitFor(selector, wait)
    test.expect.element(selector).value.to.contain(value)

  expectText: (selector, value, wait) ->
    @waitFor(selector, wait)
    test.expect.element(selector).text.to.contain(value)

  expectFlash: (value, wait) ->
    test.pause(500)
    selector = '.flash-root__message'
    @waitFor(selector, wait)
    test.expect.element(selector).text.to.contain(value)

  expectNoText: (selector, value, wait) ->
    @waitFor(selector, wait)
    test.expect.element(selector).text.to.not.contain(value)

  acceptConfirm: ->
    test.acceptAlert()
    @pause()


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
    page.click('.auth-signup-form__legal-accepted .v-input--selection-controls__input')
    page.click '.auth-signup-form__submit'
    page.expectElement '.auth-complete'
    page.loadPath 'use_last_login_token'
    page.click '.auth-signin-form__submit'

  signUpViaInvitation: (name = "New person") ->
    page = pageHelper(test)
    page.click '.auth-email-form__submit'
    page.fillIn '.auth-signup-form__name input', name
    page.click('.auth-signup-form__legal-accepted .v-input--selection-controls__input')
    page.click '.auth-signup-form__submit'

  waitFor: (selector, wait = 8000) ->
    test.waitForElementVisible(selector, wait) if selector?
