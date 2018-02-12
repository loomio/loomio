module.exports = (test) ->
  loadPath: (path) ->
    test.url "http://localhost:3000/dev/#{path}"

  goTo: (path) ->
    test.url "http://localhost:3000/#{path}"

  expectCount: (selector, count, wait) ->
    @waitFor(selector, wait)
    test.elements 'css selector', selector, (result) =>
      test.verify.equal(result.value.length, count)

  expectElement: (selector, wait) ->
    @waitFor(selector, wait)
    test.expect.element(selector).to.be.present

  expectNoElement: (selector, wait = 1000) ->
    test.expect.element(selector).to.not.be.present.after(wait)

  click: (selector, wait) ->
    @waitFor(selector, wait)
    test.click(selector)

  scrollTo: (selector, callback, wait) ->
    @waitFor(selector, wait)
    test.getLocationInView(selector, callback)

  ensureSidebar: ->
    test.elements 'css selector', '.md-sidenav-left', (result) =>
      if result.value.length == 0
        test.click('.navbar__sidenav-toggle')
        @waitFor('.md-sidenav-left')

  pause: (time = 1000) ->
    test.pause(time)

  mouseOver: (selector, x, y, wait) ->
    @waitFor(selector, wait)
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
