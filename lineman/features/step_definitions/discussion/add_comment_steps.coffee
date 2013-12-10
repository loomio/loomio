module.exports = ->
  @World = require("../../support/world.coffee").World

  @Given /^I am signed in, viewing a discussion$/, (callback) ->
    @browser.get('http://localhost:9001/discussions/1').then ->
      callback()

  @When /^I add a comment to the discussion$/, (callback) ->
    el = @browser.findElement(@By.tagName 'input')
    el.clear
    el.sendKeys('Yo wassup').then ->
      callback()

  @Then /^I should see the comment has been appended to the discussion$/, (callback) ->
    @browser.findElement(@By.tagName 'span').getText().then (text) =>
      @assert.equal text, 'Yo wassup'
      callback()
