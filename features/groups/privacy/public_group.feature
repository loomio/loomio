Feature: Coordinator sets group privacy to public
  As a group coordinator
  I want to make the group public
  So that anyone can see it

  Background:
    Given I am logged in

  Scenario: Coordinator sets group privacy to public
    Given I am a coordinator of a secret group
    When I visit the group settings page
    And I set the group to public
    Then the group should be set to public

  @javascript
  Scenario: Visitor views public group
    Given a public group exists
    And the group has a discussion
    When I visit the group page
    Then I should see the discussion title

  @javascript
  Scenario: Group member views public group
    Given I am a member of a public group
    And the group has discussions
    When I visit the group page
    Then I should see the group's discussions

  @javascript
  Scenario: Visitor views a public sub-group
    Given a public sub-group exists
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should see the sub-group's discussions
    When I visit the parent-group page
    Then I should see the sub-group's discussions

  @javascript
  Scenario: Sub-group member views public sub-group
    Given I am a member of a public sub-group
    And the sub-group has discussions
    When I visit the sub-group page
    Then I should see the sub-group's discussions
    When I visit the parent-group page
    Then I should see the sub-group's discussions
