Feature: Mention user
  In order for users to effectively talk to each other
  A user must be able to mention another user in a comment

Background:
  Given a group "demo-group" with "furry@example.com" as admin
  And I am logged in as "furry@example.com"

Scenario: Mention user in comment
  Given I am viewing a discussion titled "hello" in "demo-group"
  When I mention "Test_User" in my comment
  Then I should Should see a pop up for mentioning "Test_User"
  And I should be able to mention "Test_User"