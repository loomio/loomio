module.exports = ->
  @World = require("../../support/world.coffee").World

  @When /^I click 'Start a proposal'$/, (callback) ->
    @browser.findElement(@by.css('.cuke-show-new-proposal-form-btn')).click().then =>
      callback()

  @When /^I fill in and submit the proposal form$/, (callback) ->
    @browser.findElement(@by.id('proposal-title-field')).sendKeys('Prop 55').then =>
      @browser.findElement(@by.id('proposal-description-field')).sendKeys('We make gravy while the sun shines').then =>
        @browser.findElement(@by.css('.cuke-submit-proposal-btn')).click().then =>
          callback()

  @Then /^I'll see the new proposal discussion item$/, (callback) ->
    @browser.findElement(@by.css('.cuke-new-proposal-item')).getText().then (text) =>
      if text.match(/created a proposal/)
        callback()
      else
        callback.fail()

  @Then /^the proposal should be running$/, (callback) ->
    @browser.findElement(@by.css('.cuke-current-proposal')).getText().then (text) =>
      callback.pending()
      #@assert.equal text, "created a proposal"

