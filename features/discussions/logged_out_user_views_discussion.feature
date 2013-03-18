Feature: Logged out user views a discussion
  As a Logged out user
  So that I can observe other groups processes
  I want to view a discussion for a group I am not a member of

Scenario: Logged out user views another groups discussion
  Given there is a discussion in a group
  And I am not a member of the group
  When I visit the discussion page
  Then I should see the discussion
  And I should not see discussion options dropdown