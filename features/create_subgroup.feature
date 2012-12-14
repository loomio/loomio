  Feature: Create sub group

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"
    And I visit create subgroup page for group named "demo-group"

  Scenario: Create public subgroup where all group members can invite
    When I fill details for public all members invite subgroup
    Then a new sub-group should be created

  Scenario: Create public subgroup where only admin can invite
    When I fill details for public admin only invite subgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"

  Scenario: Create members only subgroup where all group members can invite
    When I fill details for members only all members invite subgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"

  Scenario: Create members only subgroup where only admin can invite
    When I fill details for members only admin invite subgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"

  Scenario: Create members and parent members only subgroup where all group members can invite
    When I fill details for members and parent members only all members invite subgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"

  Scenario: Create members and parent members only subgroup where only admin can invite
    When I fill details for members and parent members admin only invite ubgroup
    And I click "Create sub-group"
    Then I should see "Group created successfully"
