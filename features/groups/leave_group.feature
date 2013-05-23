Feature: Leave Group
  In order to allow users to withdraw from participating in a group
  Users must be able to leave groups

  @javascript
  Scenario: Group member leaves group
    Given I am logged in
    And I am a member of a group
    And there is another admin in the group also
    When I visit the group page
    And I choose to leave the group
    Then I should be removed from the group
