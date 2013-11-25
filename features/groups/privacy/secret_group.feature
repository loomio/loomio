Feature: Coordinator sets group privacy to secret
  As a group coordinator
  I want to make the group secret
  So only members know it exists

  Background:
    Given I am logged in

  Scenario: Coordinator sets group privacy to secret
    Given I am a coordinator of a public group
    When I visit the group settings page
    And I set the group to secret
    Then the group should be set to secret

  @javascript
  Scenario: Non-member tries to view secret group
    Given a secret group exists
    And the group has discussions
    When I visit the group page
    Then I should not see the group's discussions

  @javascript
  Scenario: Group member views secret group
    Given I am a member of a secret group
    And the group has discussions
    When I visit the group page
    Then I should see the group's discussions

  @javascript
  Scenario: Non-member tries to view secret sub-group
    Given a secret sub-group exists
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should not see the sub-group's discussions
    When I visit the parent-group page
    Then I should not see the sub-group's discussions

  @javascript
  Scenario: Sub-group member views secret sub-group
    Given I am a member of a secret sub-group
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should see the sub-group's discussions
    When I visit the parent-group page
    Then I should see the sub-group's discussions
