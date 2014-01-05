Feature: Coordinator sets group privacy to hidden
  As a group coordinator
  I want to make the group hidden
  So only members know it exists

  Background:
    Given I am logged in

  Scenario: Coordinator sets group privacy to hidden
    Given I am a coordinator of a public group
    When I visit the group settings page
    And I set the group to hidden
    Then the group should be set to hidden

  Scenario: Non-member tries to view hidden group
    Given a hidden group exists
    And the group has discussions
    When I visit the group page
    Then I should not see the group's discussions

  Scenario: Member views hidden group
    Given I am a member of a hidden group
    And the group has discussions
    When I visit the group page
    Then I should see the group's discussions

  Scenario: Non-member tries to view hidden sub-group
    Given a hidden sub-group exists
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should not see the sub-group's discussions

  Scenario: Member views hidden sub-group
    Given I am a member of a hidden sub-group
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should see the sub-group's discussions
