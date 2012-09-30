Feature: Edit group settings
  In order for groups to be customized to suit the users' needs
  Administrators of a group must be able to edit group settings

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And "non-admin@example.com" is a non-admin of group "demo-group"
    
  Scenario: Non-admin cannot edit group settings
    Given I am logged in as "non-admin@example.com"
    Then I should not have access to group settings of "demo-group"
    
  Scenario: Change group visibility to public
    Given I am logged in as "furry@example.com"
    When I visit the group settings page
    And I update the settings to public
    Then the group should be public

  Scenario: Change group visibility to Members only
    Given I am logged in as "furry@example.com"
    When I visit the group settings page
    And I update the settings to members only
    Then the group should be private

  Scenario: Change group name
    Given I am logged in as "furry@example.com"
    When I visit the group settings page
    And I update the group name
    Then the group name is changed

  Scenario: Change group invitations to allow all members
    Given I am logged in as "furry@example.com"
    When I visit the group settings page
    And I update the invitations to allow all members
    Then all members should be able to invite other users

  Scenario: Change group invitations to allow only admin
    Given I am logged in as "furry@example.com"
    When I visit the group settings page
    And I update the invitations to allow only admin
    Then only admin should be able to invite other users
