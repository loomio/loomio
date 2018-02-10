module.exports = (test) ->
  loadPath: (path, waitFor, wait) ->
    test.url "http://localhost:3000/dev/#{path}"
    @waitFor(waitFor, wait)

  expectElement: (selector, wait) ->
    test.expect.element(selector).to.be.present.before(wait)

  expectNoElement: (selector, wait) ->
    test.expect.element(selector).to.not.be.present.after(wait)

  click: (selector, waitFor, wait) ->
    test.click(selector)
    @waitFor(waitFor, wait)

  pause: (time = 1000) ->
    test.pause(time)

  mouseOver: (selector, waitFor, wait, opts = {}) ->
    test.moveToElement(selector, opts.x || 0, opts.y || 0)
    @waitFor(waitFor, wait)

  fillIn: (selector, value, waitFor, wait) ->
    test.setValue(selector, value)
    @waitFor(waitFor, wait)

  selectOption: (selector, option) ->
    # TODO
    # @click selector
    # element(By.cssContainingText('md-option', option)).click()

  expectText: (selector, value) ->
    test.expect.element(selector).text.to.contain(value)

  expectNoText: (selector, value) ->
    test.expect.element(selector).text.to.not.contain(value)

  waitFor: (waitFor, wait = 4000) ->
    test.waitForElementVisible(waitFor, wait) if waitFor?
