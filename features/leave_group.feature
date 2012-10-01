Feature: Leave Group
  In order to allow users to withdraw from participating in a group
  Users must be able to leave groups

  Scenario: As a non admin member I should be able to leave the group
    Given I am logged in as a non admin user of the group
    When I leave the group
    Then I should be removed from the group