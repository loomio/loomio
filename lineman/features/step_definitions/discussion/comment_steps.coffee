module.exports = ->
  @World = require("../../support/world.coffee").World


  @Given /^I am signed in and viewing a discussion$/, (callback) ->
    @driver.get('http://localhost:3000/angular_support/log_in_and_redirect_to_discussion').then =>
      callback()

  @Given /^there is a comment on the discussion$/, (callback) ->
    @driver.get('http://localhost:3000/angular_support/add_comment_to_discussion_and_redirect').then =>
      callback()

  @When /^I add a comment to the discussion$/, (callback) ->
    @browser.findElement(@by.id('fake_comment_input')).click().then =>
      @browser.findElement(@by.id('comment-field')).sendKeys('I im here from ear to ear').then =>
        @browser.findElement(@by.id('post-comment-btn')).click().then =>
          callback()

  @Then /^I should see the comment has been appended to the discussion$/, (callback) ->
    @browser.findElement(@by.css('.comment-body')).getText()
    # express the regexp above with the code you wish you had
    callback.pending()

  @When /^I click like on the comment$/, (callback) ->
    # express the regexp above with the code you wish you had
    callback.pending()

  @Then /^I should see that I have liked the comment$/, (callback) ->
    # express the regexp above with the code you wish you had
    callback.pending()

    #@browser.get('http://localhost:8000/discussions/1').then ->
      #done()

  #@When /^I add a comment to the discussion$/, (callback) ->
    #el = @browser.findElement(@by.tagName 'input')
    #el.clear
    #el.sendKeys('Yo wassup').then ->
      #callback()

  #@Then /^I should see the comment has been appended to the discussion$/, (callback) ->
    #@browser.findElement(@by.tagName 'span').getText().then (text) =>
      #@assert.equal text, 'Yo wassup'
      #callback()
