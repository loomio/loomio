Feature: Non-member views group
  As a non-member of a group
  So that I can view a group's public discussions and information
  I want to see the group's public info

  Scenario: Logged out user viewing public group cannot see private data
    Given a public group exists
    And the group has discussions
    And "newuser@example.org" has been invited to the group
    When I visit the group page
    Then I should see the group's discussions
    But I should not see the list of invited users
