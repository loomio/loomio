Feature: Mention user
  In order for users to effectively talk to each other
  A user must be able to mention another user in a comment

Background:
  Given a group "demo-group" with "furry@example.com" as admin
  And I am logged in as "furry@example.com"

Scenario: Mention user when writing a comment
  Given "harry@example.com" is a member of "demo-group"
  And I am viewing a discussion titled "hello" in "demo-group"
  When I am adding a comment and type in "@h"
  And I click on "@harry" in the menu that pops up
  Then I should see "@harry" added to the "new-comment" field

Scenario: Mentioned user gets emailed
  Given "harry@example.com" is a member of "demo-group"
  And I am viewing a discussion titled "hello" in "demo-group"
  And no emails have been sent
  And harry wants to be emailed when mentioned
  When I write and submit a comment that mentions harry
  Then harry should get an email saying I mentioned him

Scenario: Submit a comment mentioning a group member
  Given "harry@example.com" is a member of "demo-group"
  And I am viewing a discussion titled "hello" in "demo-group"
  When I submit a comment mentioning "@harry"
  Then the user should be notified that they were mentioned

Scenario: Submit a comment mentioning a group non-member
  Given "harry@example.com" is a member of "a different group"
  And I am viewing a discussion titled "hello" in "demo-group"
  When I submit a comment mentioning "@harry"
  Then the user should not be notified that they were mentioned

Scenario: View comment with mentions
  Given "harry@example.com" is a member of "demo-group"
  And I am viewing a discussion titled "hello" in "demo-group"
  And a comment exists mentioning "@harry"
  Then I should see a link to "harry"'s user
