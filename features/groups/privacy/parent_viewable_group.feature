Feature: User views group
  As a Loomio user
  So that I can see what groups are discussing
  I want to see all the public discussions belonging to a group

  Background:
    Given I am logged in

  Scenario: Coordinator makes subgroup viewable to parent members
    Given I am a coordinator of a hidden subgroup
    When I visit the edit subgroup page
    And I set the subgroup to be viewable by parent members
    Then the subgroup should be viewable by parent members

  Scenario: Viewable by parent option does not show up for parent groups

  Scenario: Sub-group member views visible-to-parent sub-group
    Given I am a member of a sub-group viewable by parent-group members
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should see the sub-group's discussions

  Scenario: Parent-group member views sub-group viewable by parent-group members
    Given I am a member of a parent-group that has a sub-group viewable by parent-group members
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should see the sub-group's discussions

  Scenario: Parent-group non-member tries to view sub-group viewable by parent-group members
    Given I am not a member of a parent-group that has a sub-group viewable by parent-group members
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should not see the sub-group's discussions
