Feature: Coordinator sets group privacy to private
  As a group coordinator
  I want to make the group private
  So that anyone can see it but only members can see discussions

  Background:
    Given I am logged in

  Scenario: Coordinator sets group privacy to private
    Given I am a coordinator of a secret group
    When I visit the group settings page
    And I set the group to private
    Then the group should be set to private

  Scenario: Visitor views private group
    Given a private group exists
    And the group has a discussion
    When I visit the group page
    Then I should see the group members
    And I should not see the discussion
    And I should not see previous decisions

  Scenario: Group member views private group
    Given I am a member of a private group
    And the group has discussions
    When I visit the group page
    Then I should see the group's discussions

  Scenario: Visitor views a private subgroup
    Given a private sub-group exists
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should see the group members
    And I should not see the sub-group's discussions
    And I should not see previous decisions

  Scenario: Subgroup member views private subgroup
    Given I am a member of a private sub-group
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should see the sub-group's discussions
