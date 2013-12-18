myHooks = ->
  @Before (callback) ->
    callback()

  @After (callback) ->
    #@emptyDatabase()
    #@shutdownFullTextSearchServer()
    @driver.quit()
    
    callback()
    


module.exports = myHooks
