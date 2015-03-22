Feature: Edit group settings
  In order for groups to be customized to suit the users' needs
  Administrators of a group must be able to edit group settings

  @javascript
  Scenario: Change all the privacy settings on a parent group
    Given I am the logged in admin of a group
    And I visit the group settings page
    When I select listed, open, public only
    Then the group should be listed, open, public only
    When I select listed, by request, public and private
    Then the group should be listed, by request, public and private
    When I select listed, invitation only, private only
    Then the group should be listed, by request, private only
    When I select unlisted
    Then the group should be unlisted, invitation only, prviate discussions only
    When I allow the members to do everything
    Then they should be allowed to do everything
    When I disallow the members to do everything
    Then they should be disallowed from doing everything


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

  @javascript
  Scenario: Group is made public
    Given I am the logged in admin of a group
    And I visit the group settings page
    When a group is made visible, join on request
    Then discussion privacy is set to public, and other options are disabled

  Scenario: Group is made visible, join on approval
    Given I am the logged in admin of a group
    And I visit the group settings page
    When a group is made visible, join on approval
    And all 3 discussion privacy options are available

  Scenario: Group is made private
    Given I am the logged in admin of a group
    And I visit the group settings page
    When a group is made hidden
    Then the form selects invitation only, and disables other join options
    And private discussions only is selected, other privacy options disabled
