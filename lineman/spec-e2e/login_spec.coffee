protractor = require("protractor")
require "protractor/jasminewd"
require 'jasmine-given'

describe "my angular app", ->
  ptor = protractor.getInstance()
  describe "visiting the login page", ->
    Given -> ptor.get "/"

    describe "when a user logs in", ->
      Given -> ptor.findElement(protractor.By.input("credentials.username")).sendKeys "Ralph"
      Given -> ptor.findElement(protractor.By.input("credentials.password")).sendKeys "Wiggum"
      When -> ptor.findElement(protractor.By.id("log-in")).click()
      Then -> ptor.findElement(protractor.By.binding("{{ message }}")).getText().then (text) ->
          expect(text).toEqual "Mouse Over these images to see a directive at work"




