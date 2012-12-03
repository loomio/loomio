Feature: Admin removes a discussion on Loomio
  As an admin for a group on Loomio
  So that I can remove any confusing or redundant discussions
  I want to be able to remove a discussion from my group

  Scenario: Admin removes the discussion from a group
    Given I am logged in
    And there is a discussion in a group I belong to
    And I am an admin of this group
    When I visit the discussion page
    And I select the remove discussion link from the discussion dropdown
    And I confirm this action
    Then I should be directed to the group page
    And I should not see the discussion in the list of discussions
    And I should see a message notifying me of the removal

  Scenario: A non admin tries to remove a discussion from a group
    Given I am logged in
    And there is a discussion in a group I belong to
    And I am not an admin of this group
    When I visit the discussion page
    And I should not see the remove discussion link in the discussion dropdown