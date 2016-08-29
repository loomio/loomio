_ = require 'lodash'

# support click(arg1, arg2) and click([arg1, arg2])
given =  (args) ->
  if _.isArray(args[0])
    args[0]
  else
    args

module.exports = new class StaticPageHelper

  loadPath: (path) ->
    browser.driver.get('localhost:3000/development/'+path)
    browser.driver.manage().window().setSize(1280, 1024)

  elementFor: (selector) ->
    browser.driver.findElement(By.css(selector))

  click: ->
    _.each given(arguments), (selector) =>
      @elementFor(selector).click()

  fillIn: (selector, value) ->
    elem = @elementFor(selector)
    elem.clear().then -> elem.sendKeys(value)

  expectText: (selector, value) ->
    expect(@elementFor(selector).getText()).toContain(value)

  expectFlash: (value) ->
    expect(@elementFor('.alert-message').getText()).toContain(value)
