Feature: Admin moves discussion
  As an admin
  So that I can keep my group organised
  I want to move discussions between subgroups

  Scenario: Admin moves a discussion from parent group to subgroup
    Given I am logged in
    And I am an admin of a group with a discussion
    And the group has a subgroup
    When I visit the discussion page
    And I select the move discussion link from the discussion dropdown
    And I select the destination group
    And I confirm the action
    Then I should see the destination group name in the page title

  Scenario: Admin moves a discussion from subgroup to its parent group

  Scenario: Admin moves a discussion between subgroups within the same parent group

  Scenario: User tries to move a discussion

  Scenario: Admin tries to move a discussion between parent groups

