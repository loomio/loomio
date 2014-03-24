Feature: Edit group settings
  In order for groups to be customized to suit the users' needs
  Administrators of a group must be able to edit group settings

  Background:
    Given a group "demo-group" with "admin@example.com" as admin
    And "member@example.com" is a member of group "demo-group"
    And I am logged in as "admin@example.com"
    And I visit the group settings page for "demo-group"

  Scenario: Make group public and open
    When I make the group as public as possible
    Then the group should be visible, default public, members invite

  Scenario: Make group hidden and locked down
    When I make the group as secret and locked down as possible
    Then the group should be hidden, default private, admins invite

  Scenario: Non-admin cannot edit group settings
    When I am not an admin and I access the group settings page
    Then I see I don't have permission to do this
