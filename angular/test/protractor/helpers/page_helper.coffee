_ = require 'lodash'

# support click(arg1, arg2) and click([arg1, arg2])
given =  (args) ->
  if _.isArray(args[0])
    args[0]
  else
    args

module.exports = new class PageHelper
  loadPath: (path) ->
    browser.get('development/'+path)

  expectElement: (selector)->
    expect(element(By.css(selector)).isPresent()).toBe(true)

  expectNoElement: (selector)->
    expect(element(By.css(selector)).isPresent()).toBe(false)

  click: ->
    _.each given(arguments), (selector) ->
      element(By.css(selector)).click()

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
