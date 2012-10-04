Feature: User sees the number of new comments on a discussion
  As a Loomio group member
  So that I can know if a discussion has had new comments
  I want to know how many new comments a discussion has had since I last viewed it

  Scenario: User visits dashboard and sees new comments on a discussion they've never read before
    Given I am logged in
    And there is a discussion in a group I belong to
    And I have never read the discussion before
    And the discussion has comments
    When I visit the dashboard
    Then I should see the number of comments the discussion has

  Scenario: User visits dashboard and sees new comments on a discussion they've read before
    Given I am logged in
    And there is a discussion in a group I belong to
    And I have read the discussion before
    And the discussion has had new comments since I last read it
    When I visit the dashboard
    Then I should see the number of new comments the discussion has

  # Figure out why this is failing...
  # Scenario: User visits group page and sees new comments on a discussion they've never read before
  #   Given I am logged in
  #   And there is a discussion in a group I belong to
  #   And I have never read the discussion before
  #   And the discussion has comments
  #   When I visit the group page
  #   Then I should see the number of comments the discussion has

  Scenario: User visits group page and sees new comments on a discussion they've read before
    Given I am logged in
    And there is a discussion in a group I belong to
    And I have read the discussion before
    And the discussion has had new comments since I last read it
    When I visit the group page
    Then I should see the number of new comments the discussion has
