Feature: Admin moves discussion
  As an admin
  So that I can keep my group organised
  I want to move discussions between subgroups

  Scenario: Admin moves a discussion from parent group to subgroup
    Given I am logged in
    And I am an admin of a group with a discussion
    And the group has a subgroup
    And I am an admin of the subgroup 
    When I visit the discussion page
    And I select the move discussion link from the discussion dropdown
    And I select the destination subgroup
    And I click on move
    Then I should see the destination subgroup name in the page title

  Scenario: Admin moves a discussion from subgroup to its parent group
    Given I am logged in
    And I am an admin of a group
    And the group has a subgroup
    And I am an admin of the subgroup
    And the subgroup has a discussion
    When I visit the discussion page
    And I select the move discussion link from the discussion dropdown
    And I select the destination parent group
    And I click on move
    Then I should not see the subgroup name in the page title

  Scenario: Admin moves a discussion between subgroups within the same parent group
    Given I am logged in
    And I am an admin of a group
    And the group has a subgroup
    And I am an admin of the subgroup
    And the group has another subgroup with a discussion I am an admin of
    When I visit the discussion page
    And I select the move discussion link from the discussion dropdown
    And I select the destination subgroup
    And I click on move
    Then I should see the destination subgroup name in the page title

  Scenario: User tries to move a discussion
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And the group has a subgroup
    When I visit the discussion page
    Then I try to move the discussion but I cannot see the link

  Scenario: Admin tries to move a discussion from a group with no subgroups
    Given I am logged in
    And I am an admin of a group with a discussion
    When I visit the discussion page
    Then I try to move the discussion but I cannot see the link

