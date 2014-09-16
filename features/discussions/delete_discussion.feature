Feature: Admin deletes a discussion on Loomio
  As an admin for a group on Loomio
  So that I can delete any confusing or redundant discussions
  I want to be able to delete a discussion from my group

  @javascript
  Scenario: Admin deletes the discussion from a group
    Given I am logged in
    And there is a discussion in a group I belong to
    And I am an admin of this group
    When I visit the discussion page
    And I select the delete discussion link from the discussion dropdown
    Then I should be directed to the group page
    And I should not see the discussion in the list of discussions
    And I should see a message notifying me of the deletion
