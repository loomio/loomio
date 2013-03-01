Feature: Mention user
  In order for users to effectively talk to each other
  A user must be able to mention another user in a comment

Background:
  Given I am logged in
  And I am a member of a group
  And there is a discussion in the group

Scenario: User selects a group member to mention
  Given "Harry" is a member of the group
  When I visit the discussion page
  And I am adding a comment and type in "@h"
  And I click on "@harry" in the menu that pops up
  Then I should see "@harry" added to the "new-comment" field

Scenario: User mentions a group member
  Given "Harry" is a member of the group
  And no emails have been sent
  And harry wants to be emailed when mentioned
  When I visit the discussion page
  And I write and submit a comment that mentions harry
  And I wait 5 seconds
  Then harry should get an email saying I mentioned him
  And the user should be notified that they were mentioned

Scenario: User tries to mention a group non-member
  Given "Harry" is not a member of the group
  When I visit the discussion page
  When I submit a comment mentioning "@harry"
  Then the user should not be notified that they were mentioned

Scenario: User views a comment with a mention
  Given "Harry" is a member of the group
  When I visit the discussion page
  And a comment exists mentioning "@harry"
  Then I should see a link to "harry"'s user
