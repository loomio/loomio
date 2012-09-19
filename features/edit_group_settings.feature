Feature: Edit group settings
  In order for groups to be customized to suit the users' needs
  Administrators of a group must be able to edit group settings

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"

  Scenario: Non-admin cannot edit group settings
    Given "furry@example.com" is a non-admin of group "demo-group"
    Then I should not have access to group settings

  Scenario: Change group visibility to public
    When I visit the group settings page
    And I update the settings to public
    Then the group should be public

  Scenario: Change group visibility to Members only
    When I visit the group settings page
    And I update the settings to members only
    Then the group should be private

  Scenario: Change group name
    When I visit the group settings page
    And I update the group name
    Then the group name is changed

  Scenario: Change group invitations to allow all members
    When I visit the group settings page
    And I update the invitations to allow all members
    Then all members should be able to invite other users

  Scenario: Change group invitations to allow only admin
    When I visit the group settings page
    And I update the invitations to allow only admin
    Then only admin should be able to invite other users
