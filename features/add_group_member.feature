Feature: Add member to group
  To allow multiple people to make decisions as a collective
  Users must be able to add other users to groups

  Background:
    Given a group "demo-group" with "abc@loomio.com" as admin
    And I am logged in as "abc@loomio.com"
    And "hello@world.com" is a user

  Scenario: Add existing Loomio user to group
    When I visit the group page for "demo-group"
    When I invite "hello@world.com" to the group
    Then "hello@world.com" should be added to the group

  Scenario: Add group member that is already in the group
    Given "hello@world.com" is a member of "demo-group"
    When I visit the group page for "demo-group"
    And I invite "hello@world.com" to the group
    Then I should be notified that "hello@world.com" is already a member
