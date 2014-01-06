Feature: Edit group profile
  As a group coordinator
  So that my Loomio group matches our brand identity
  I want to customise how my Loomio group looks

  Background:
    Given I am logged in
    And I am an admin of a group

  Scenario: Coordinator sets group profile image
    When I visit the group settings page
    And I upload a new group profile image
    Then the group profile image should be updated