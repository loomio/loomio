Feature: Edit group settings
  In order for groups to be customized to suit the users' needs
  Administrators of a group must be able to edit group settings

  @javascript
  Scenario: Change all the privacy settings on a parent group
    Given I am the logged in admin of a group
    And I visit the group settings page
    When I select listed, open, public only
    Then the group should be listed, open, public only
    When I select listed, by request, admins add members, public and private
    Then the group should be listed, by request, admins add members, public and private
    When I select listed, invitation only, admins add members, private only
    Then the group should be listed, by request, admins add members, private only
    When I select unlisted, admins add members
    Then the group should be unlisted, invitation only, admins add members, prviate discussions only

  @javascript
  Scenario: Change the settings on a subgroup
    Given I am the logged in admin of a group
    And I am editing the settings for a subgroup
    When I select visible to parent group members and save
    Then the subgroup should be visible to parent group members

  @javascript
  Scenario: Change the name and description
    Given I am the logged in admin of a group
    And I visit the group settings page
    When I change the group name and description
    Then the group name and description should be changed

  @javascript
  Scenario: Change from public to private discussions
    Given I am the logged in admin of a group
    And the group has a public discussion
    And I visit the group settings page
    When I change the group to private discussions only
    Then I should have to confirm making discussions private
    And the discussion should be private

  @javascript
  Scenario: Change from private to public discussions
    Given I am the logged in admin of a group
    And the group has a private discussion
    And I visit the group settings page
    When I change the group to public discussions only
    Then I should have to confirm making discussions public
    And the discussion should be public
