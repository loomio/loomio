_ = require 'lodash'

module.exports = class BaseHelper
  loadPath: (path) ->
    browser.get('http://localhost:8000/development/'+path)

  expectCSS: (selector)->
    expect(element(By.css(selector)).isPresent()).toBe(true)

  expectNotCSS: (selector)->
    expect(element(By.css(selector)).isPresent()).toBe(true)

  click: ->
    _.each arguments, (selector) ->
      element(By.css(selector)).click()
