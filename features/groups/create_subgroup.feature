  Feature: Create sub group

  Background:
    Given I am logged in
    And I am an admin of a group
    And I visit the group page
    And I visit create subgroup page

  @javascript
  Scenario: Create public subgroup where all group members can invite
    When I fill details for public all members invite subgroup
    Then a new sub-group should be created

  @javascript
  Scenario: Create public subgroup where only admin can invite
    When I fill details for public admin only invite subgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"

  @javascript
  Scenario: Create members only subgroup where all group members can invite
    When I fill details for members only all members invite subgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"

  @javascript
  Scenario: Create members only subgroup where only admin can invite
    When I fill details for members only admin invite subgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"

  @javascript
  Scenario: Create members and parent members only subgroup where all group members can invite
    When I fill details for members and parent members only all members invite subgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"

  @javascript
  Scenario: Create members and parent members only subgroup where only admin can invite
    When I fill details for members and parent members admin only invite ubgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"
