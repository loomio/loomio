steps = ->
  @World = require("../support/world.js").World # overwrite default World constructor

  @Given /^I am signed in, viewing a discussion$/, (callback) ->
    
    # express the regexp above with the code you wish you had
    callback.pending()

  @When /^I add a comment to the discussion$/, (callback) ->
    
    # express the regexp above with the code you wish you had
    callback.pending()

  @Then /^I should see the comment has been appended to the discussion$/, (callback) ->
    
    # express the regexp above with the code you wish you had
    callback.pending()
  
  @Given /^I am on the Cucumber.js GitHub repository$/, (callback) ->
    # Express the regexp above with the code you wish you had.
    # `this` is set to a new this.World instance.
    # i.e. you may use this.browser to execute the step:
    @visit "http://github.com/cucumber/cucumber-js", callback

  # The callback is passed to visit() so that when the job's finished, the next step can
  # be executed by Cucumber.
  @When /^I go to the README file$/, (callback) ->
    # Express the regexp above with the code you wish you had. Call callback() at the end
    # of the step, or callback.pending() if the step is not yet implemented:
    callback.pending()

  @Then /^I should see "(.*)" as the page title$/, (title, callback) ->
    # matching groups are passed as parameters to the step definition
    pageTitle = @browser.text("title")
    if title is pageTitle
      callback()
    else
      callback.fail new Error("Expected to be on page with title " + title)


module.exports = steps
