Feature: Non-member views group
  As a non-member of a group
  So that I can view a group's public discussions and information
  I want to see the group's public info

  @javascript
  Scenario: Logged out user viewing public group cannot see private data
    Given a public group exists
    And the group has discussions
    When I visit the group page
    Then I should see the group's discussions
