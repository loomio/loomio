myHooks = ->
  @Before (callback) ->
    
    # Just like inside step definitions, "this" is set to a World instance.
    # It's actually the same instance the current scenario step definitions
    # will receive.
    
    # Let's say we have a bunch of "maintenance" methods available on our World
    # instance, we can fire some to prepare the application for the next
    # scenario:
    @bootFullTextSearchServer()
    @createSomeUsers()
    
    # Don't forget to tell Cucumber when you're done:
    callback()

  @After (callback) ->
    
    # Again, "this" is set to the World instance the scenario just finished
    # playing with.
    
    # We can then do some cleansing:
    @emptyDatabase()
    @shutdownFullTextSearchServer()
    
    # Release control:
    callback()
    


module.exports = myHooks
