Feature: Join Group
  As a user
  So that I can participate in a group
  I want to join a group

  @javascript
  Scenario: User joins open group
    Given I am logged in
    And a join instanty group exists
    When I visit the group page
    And I click "Join group"
    Then I should be a member of the group
