protractor = require("protractor")
require "protractor/jasminewd"
require 'jasmine-given'

describe "Discussions", ->
  ptor = protractor.getInstance()
  describe "Adding a comment", ->
    Given -> ptor.get "/discussions/7772"

    describe "Adding a comment", ->
      #Given -> ptor.findElement(protractor.By.input("credentials.username")).sendKeys "Ralph"
      #Given -> ptor.findElement(protractor.By.input("credentials.password")).sendKeys "Wiggum"
      When -> ptor.findElement(protractor.By.id("fake_comment_input")).click()
      Then -> ptor.findElement(protractor.By.binding("{{ message }}")).getText().then (text) ->
          expect(text).toEqual "Mouse Over these images to see a directive at work"




