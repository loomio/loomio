  Feature: User edits discussion title
  As a Loomio user
  I want to be able to edit the discussion title
  So I can provide a clear context for the discussion

Scenario: User edits the discussion description
  Given I am logged in
  And I am an admin of a group with a discussion
  And I am on the discussion page
  When I choose to edit the discussion title
  And I fill in and submit the discussion title form
  Then I should see the title change
  And I should see a record of my title change in the discussion feed

Scenario: User tries to edit the discussion description when they don't belong to the group
  Given there is a discussion in a group
  And I am not an admin of this group
  When I visit the discussion page
  Then I should not see a link to edit the title
