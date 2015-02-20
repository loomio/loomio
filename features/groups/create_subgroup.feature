  Feature: Create sub group

  Background:
    Given I am logged in
    And I am an admin of a group
    And I visit the group page
    And I visit create subgroup page

  @javascript
  Scenario: Create visible, public allowed, members invitable subgroup
    When I create a totally open subgroup
    Then a totally open subgroup should be created

  @javascript
  Scenario: Create visible to parent members subgroup
    When I create a visible to parent members subgroup
    Then a visible to parent members subgroup should be created

  @javascript
  Scenario: Create hidden, private only, no inheritance, admins invite subgroup
    When I create a locked down subgroup
    Then a locked down subgroup should be created

  @javascript
  Scenario: Subgroups do not have permissions around creating subgroups
    When I view the subgroup permissions tab
    Then I should not see an option to give members permission to create subgroups
