module.exports = (test) ->
  loadPath: (path) ->
    test.url "http://localhost:3000/dev/#{path}"

  goTo: (path) ->
    test.url "http://localhost:3000/#{path}"

  expectElement: (selector, wait) ->
    @waitFor(selector, wait)
    test.expect.element(selector).to.be.present

  expectNoElement: (selector, wait = 1000) ->
    test.expect.element(selector).to.not.be.present.after(wait)

  click: (selector, wait) ->
    @waitFor(selector, wait)
    test.click(selector)

  pause: (time = 1000) ->
    test.pause(time)

  mouseOver: (selector, x, y) ->
    test.moveToElement(selector, x || 0, y || 0)

  fillIn: (selector, value, wait) ->
    @waitFor(selector, wait)
    test.clearValue(selector)
    test.setValue(selector, value)

  selectOption: (selector, option) ->
    # TODO
    # @click selector
    # element(By.cssContainingText('md-option', option)).click()

  expectText: (selector, value, wait) ->
    @waitFor(selector, wait)
    test.expect.element(selector).text.to.contain(value)

  expectNoText: (selector, value, wait) ->
    @waitFor(selector, wait)
    test.expect.element(selector).text.to.not.contain(value)

  waitFor: (selector, wait = 4000) ->
    test.waitForElementVisible(selector, wait) if selector?
