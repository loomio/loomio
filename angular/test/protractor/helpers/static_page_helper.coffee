_ = require 'lodash'

# support click(arg1, arg2) and click([arg1, arg2])
given =  (args) ->
  if _.isArray(args[0])
    args[0]
  else
    args

module.exports = new class StaticPageHelper

  ignoreSynchronization: (fn) ->
    browser.ignoreSynchronization = true
    fn()
    browser.ignoreSynchronization = false

  loadPath: (path) ->
    browser.driver.get('http://localhost:3000/dev/'+path)
    browser.driver.manage().window().setSize(1280, 1024)
    browser.driver.sleep(1000)

  elementFor: (selector) ->
    browser.driver.findElement(By.css(selector))

  click: ->
    _.each given(arguments), (selector) =>
      @elementFor(selector).click()
    browser.driver.sleep(2000)

  fillIn: (selector, value) ->
    elem = @elementFor(selector)
    elem.clear().then -> elem.sendKeys(value)

  expectText: (selector, value) ->
    expect(@elementFor(selector).getText()).toContain(value)

  expectFlash: (value) ->
    expect(@elementFor('.alert-message').getText()).toContain(value)
