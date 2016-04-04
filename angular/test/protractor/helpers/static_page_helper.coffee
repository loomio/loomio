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

  click: (selector) ->
    browser.driver.findElement(By.css(selector))
    _.each given(arguments), (selector) ->
      element(By.css(selector)).click()

  click: ->
    _.each given(arguments), (selector) ->
      browser.driver.findElement(By.css(selector)).click()

  fillIn: (selector, value) ->
    browser.driver.findElement(By.css(selector)).sendKeys(value)
