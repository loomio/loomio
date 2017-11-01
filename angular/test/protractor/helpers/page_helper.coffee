_ = require 'lodash'

# support click(arg1, arg2) and click([arg1, arg2])
given =  (args) ->
  if _.isArray(args[0])
    args[0]
  else
    args

jasmine.DEFAULT_TIMEOUT_INTERVAL = 60000

module.exports = new class PageHelper
  loadPath: (path, timeout = jasmine.DEFAULT_TIMEOUT_INTERVAL) ->
    browser.get('dev/'+path, timeout)

  waitForReload: (time=2000)->
    browser.driver.sleep(time)
    browser.waitForAngular()

  sleep: (time=1000) ->
    browser.driver.sleep(time)

  expectElement: (selector)->
    expect(element(By.css(selector)).isPresent()).toBe(true)

  expectNoElement: (selector)->
    expect(element(By.css(selector)).isPresent()).toBe(false)

  expectDisabledElement: (selector)->
    expect(element(By.css(selector)).isEnabled()).toBe(false)

  click: ->
    _.each given(arguments), (selector) ->
      element(By.css(selector)).click()

  clickFirst: (selector) ->
    @findFirst(selector).click()

  clickLast: (selector) ->
    @findLast(selector).click()

  findFirst: (selector) ->
    element.all(By.css(selector)).first()

  findLast: (selector) ->
    element.all(By.css(selector)).last()

  fillIn: (selector, value) ->
    element(By.css(selector)).clear().sendKeys(value)

  fillInAndEnter: (selector, value) ->
    element(By.css(selector)).clear().sendKeys(value).sendKeys(browser.driver.keys('Enter'))

  selectOption: (selector, option) ->
    @click selector
    element(By.cssContainingText('md-option', option)).click()

  expectInputValue: (selector, value) ->
    expect(element(By.css(selector)).getAttribute('value')).toContain(value)

  expectText: (selector, value) ->
    expect(element(By.css(selector)).getText()).toContain(value)

  expectNoText: (selector, value) ->
    expect(element(By.css(selector)).getText()).not.toContain(value)

  expectFlash: (text) ->
    @expectText('.flash-root__message', text)

  cancelConfirmDialog: ->
    browser.switchTo().alert().dismiss()

  acceptConfirmDialog: ->
    browser.switchTo().alert().accept()

  expectSelected: ->
    _.each given(arguments), (selector) ->
      element(By.css("#{selector}.md-checked")).isSelected().then (selected) ->
        if !selected
          console.log "unexpected not selected", selector, selected
        expect(selected).toBe(true)

  expectNotSelected: ->
    _.each given(arguments), (selector) ->
      element(By.css(selector)).isSelected().then (selected) ->
        if selected
          console.log "unexpected selected", selector, selected
        expect(selected).toBe(false)

  signInViaPassword: (email, password) ->
    @fillIn '.auth-email-form__email input', email
    @click '.auth-email-form__submit'
    @fillIn '.auth-signin-form__password input', password
    @click '.auth-signin-form__submit'

  signInViaEmail: (email) ->
    @fillIn '.md-input', 'new@account.com'
    @click '.auth-email-form__submit'
    @fillIn '.md-input', 'New Account'
    @click '.auth-signup-form__submit'
    @loadPath 'use_last_login_token'
    @click '.auth-signin-form__submit'
