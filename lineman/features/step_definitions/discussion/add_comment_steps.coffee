module.exports = ->
  @World = require("../../support/world.coffee").World

  @Given /^I am signed in, viewing a discussion$/, (done) ->
    @driver.get('http://localhost:3000/angular_support/log_in_and_redirect_to_discussion').then =>
      done()

  @When /^I add a comment to the discussion$/, (callback) ->
    @browser.findElement(@by.id('fake_comment_input')).click().then =>
      @browser.findElement(@by.id('comment-field')).sendKeys('I im here from ear to ear').then =>
        @browser.findElement(@by.id('post-comment-btn')).click().then =>
          console.log @browser.findElement(@by.css('.comment-body')).getText()


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
