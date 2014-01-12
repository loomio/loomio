Feature: Admin moves discussion
  As an admin
  So that I can keep my group organised
  I want to move discussions between subgroups

  @javascript
  Scenario: Admin moves a discussion
    Given I am logged in
    And I am an admin of a group with a discussion
    And the group has a subgroup
    And I am an admin of the subgroup
    When I visit the discussion page
    And I select the move discussion link from the discussion dropdown
    And I select the destination subgroup
    And I click on move
    Then I should see the destination subgroup name in the page title
