Feature: View subgroup discussions from parent group
  As a member
  I want to see discussions in subgroups I belong to, directly from the parent group page
  So that I can get an overview of all the activity happening in the group

  Background:
    Given I am logged in

  Scenario: When viewing parent group, visitor sees all public subgroup discussions
    Given a public sub-group exists
    And the sub-group has discussions
    When I visit the parent-group page
    Then I should see the sub-group's discussions

  Scenario: When viewing parent group, visitor does not see secret subgroup discussions
    Given a secret sub-group exists
    And the sub-group has discussions
    When I visit the parent-group page
    Then I should not see the sub-group's discussions

  Scenario: When viewing parent group, member doesn't see discussions for subgroups they don't belong to
    Given I am a member of a parent-group that has sub-groups I don't belong to
    And those sub-groups have discussions
    When I visit the parent-group page
    Then I should not see those sub-groups' discussions

  Scenario: When viewing parent group, member sees discussions for public subgroups they belong to
    Given I am a member of a public sub-group
    And the sub-group has discussions
    When I visit the parent-group page
    Then I should see the sub-group's discussions

  Scenario: When viewing parent group, member sees discussions for secret subgroups they belong to
    Given I am a member of a secret sub-group
    And the sub-group has discussions
    When I visit the parent-group page
    Then I should see the sub-group's discussions
