myHooks = ->
  @Before (callback) ->
    callback()

  @After (callback) ->
    @driver.quit()
    callback()

module.exports = myHooks
