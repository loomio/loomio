Feature: Mention user
  In order for users to effectively talk to each other
  A user must be able to mention another user in a comment

Background:
  Given a group "demo-group" with "furry@example.com" as admin
  And I am logged in as "furry@example.com"

Scenario: Mention user in comment
  Given "harry@example.com" is a member of "demo-group"
  And I am viewing a discussion titled "hello" in "demo-group"
  When I am adding a comment and type in "@h"
  And I click on "@harry" in the menu that pops up
  Then I should see "@harry" added to the "new-comment" field
  
Scenario: View comment with mentions
  Given "harry@example.com" is a member of "demo-group"
  And I am viewing a discussion titled "hello" in "demo-group"
  And a comment exists mentioning "@harry"
  Then I should see a link to "harry"'s user
