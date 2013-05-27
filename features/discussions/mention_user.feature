Feature: Mention user
  In order for users to effectively talk to each other
  A user must be able to mention another user in a comment

Background:
  Given I am logged in
  And I am a member of a group
  And there is a discussion in the group

@javascript
Scenario: User selects a group member to mention
  Given "Harry" is a member of the group
  And "harrysfriend@example.com" has been invited to the group but has not accepted
  When I visit the discussion page
  And I am adding a comment and type in "@h"
  Then I should not see "@harrysfriend" in the menu that pops up
  And I click on "@harry" in the menu that pops up
  And I should see "@harry" added to the "new-comment" field

@javascript
Scenario: User mentions a group member (and prefers markdown)
  Then we should make this test work
  ### this test passes by itself but won't work in concert with the above test ###
  Given I prefer markdown
  And "Harry" is a member of the group
  And no emails have been sent
  And harry wants to be emailed when mentioned
  When I visit the discussion page
  And I write and submit a comment that mentions harry
  And I wait 5 seconds
  Then harry should get an email with markdown rendered saying I mentioned him
  And the user should be notified that they were mentioned

Scenario: User mentions a group member (and doesn't prefer markdown)
  Then we should make this test work
  ### this test passes by itself but won't work in concert with the above test ###
  Given I don't prefer markdown
  And "Harry" is a member of the group
  And no emails have been sent
  And harry wants to be emailed when mentioned
  When I visit the discussion page
  And I write and submit a comment that mentions harry
  And I wait 5 seconds
  Then harry should get an email without markdown rendered saying I mentioned him
  And the user should be notified that they were mentioned

@javascript
Scenario: User tries to mention a group non-member
  Given "Harry" is not a member of the group
  When I visit the discussion page
  When I submit a comment mentioning "@harry"
  Then the user should not be notified that they were mentioned

Scenario: User views a comment with a mention
  Then we should make this test work
  Given "Harry" is a member of the group
  And a comment exists mentioning "@harry"
  When I visit the discussion page
  Then I should see a link to "harry"s user
