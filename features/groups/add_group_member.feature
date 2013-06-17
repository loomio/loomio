Feature: Member adds user to group
  As a member of a group
  So that we can have discussions and make decisions
  I want to add other users to my group

  Background:
    Given I am logged in

  @javascript
  Scenario: Subgroup member adds members to subgroup
    Given I am a member of a group
    And I am a member of a subgroup invitable by members
    And "David" is a member of the group
    And "Joe" is a member of the group
    When I visit the subgroup page
    And I click add new member
    And I select "David" from the list of members
    And I select "Joe" from the list of members
    And I confirm the selection
    Then I should see "David" as a member of the subgroup
    And I should see "Joe" as a member of the subgroup

  Scenario: Subgroup member cannot add members to a subgroup invitable by admins
    Given I am a member of a group
    And I am a member of a subgroup invitable by admins
    When I visit the subgroup page
    Then I should not see the add member button
