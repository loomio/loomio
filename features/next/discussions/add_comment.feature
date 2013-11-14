Feature: Add a comment to a discussion

Background:
  Given I am logged in
  And there is a discussion in a group I belong to
  And I am looking the mobile version of the discussion

@javascript
Scenario: User comments on discussion
  When I click on the add comment box
  And I enter a comment and post it
  Then I should see the comment added to the discussion
