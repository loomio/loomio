_ = require 'lodash'

# support click(arg1, arg2) and click([arg1, arg2])
given =  (args) ->
  if _.isArray(args[0])
    args[0]
  else
    args

jasmine.DEFAULT_TIMEOUT_INTERVAL = 50000

module.exports = new class PageHelper
  loadPath: (path) ->
    browser.get('development/'+path)
    browser.driver.manage().window().setSize(1280, 1024)

  waitForReload: (time=1000)->
    browser.driver.sleep(time)
    browser.waitForAngular()

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
    element.all(By.css(selector)).first().click()

  clickLast: (selector) ->
    element.all(By.css(selector)).last().click()

  findFirst: (selector) ->
    element.all(By.css(selector)).first()

  fillIn: (selector, value) ->
    element(By.css(selector)).clear().sendKeys(value)

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
      element(By.css(selector)).isSelected().then (selected) ->
        if !selected
          console.log "unexpected not selected", selector, selected
        expect(selected).toBe(true)

  expectNotSelected: ->
    _.each given(arguments), (selector) ->
      element(By.css(selector)).isSelected().then (selected) ->
        if selected
          console.log "unexpected selected", selector, selected
        expect(selected).toBe(false)
