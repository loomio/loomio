Feature: Archive group
  As a group coordinator
  So that I can remove groups I not longer want
  I want to be able to archive groups

  Background:
    Given I am logged in
    And I am an admin of a group with a public discussion
    And I visit the group page

  @javascript
  Scenario: Group coordinator archives group
    When I archive my group
    Then my group should be archived
    And group discussions should be removed from the dashboard
    And I should not be able to view specific discussions
