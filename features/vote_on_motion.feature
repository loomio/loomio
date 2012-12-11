Feature: User votes on a motion
  In order to allow groups a way to decide on issues
  Users must be able to vote on a motion

  # Scenario: As a logged in member I should be able to vote 'yes' on a proposal
  #   Given I am logged in
  #   And there is a discussion in a group I belong to
  #   And the discussion has an open proposal
  #   When I visit the discussion page
  #   And I click the 'yes' vote button
  #   And I enter a statement
  #   Then I should see new vote in the activity feed
  #   And I should see my vote in the list of positions

  # Scenario: As a logged in member I should be able to 'abstain' on a proposal
  #   Given I am logged in
  #   And there is a discussion in a group I belong to
  #   And the discussion has an open proposal
  #   When I visit the discussion page
  #   And I click the 'abstain' vote button
  #   And I enter a statement
  #   Then I should see new vote in the activity feed
  #   And I should see my vote in the list of positions

  # Scenario: As a logged in member I should be able to vote 'no' on a proposal
  #   Given I am logged in
  #   And there is a discussion in a group I belong to
  #   And the discussion has an open proposal
  #   When I visit the discussion page
  #   And I click the 'no' vote button
  #   And I enter a statement
  #   Then I should see new vote in the activity feed
  #   And I should see my vote in the list of positions

  Scenario: As a logged in member I should be able to vote 'block' on a proposal
    Given I am logged in
    And there is a discussion in a group I belong to
    And the discussion has an open proposal
    When I visit the discussion page
    And I click the 'block' vote button
    And I enter a statement for my block
    Then I should see my block in the activity feed
    And I should see my vote in the list of positions

  Scenario: As a logged in member I should be able to edit my vote on a proposal
    Given I am logged in
    And there is a discussion in a group I belong to
    And the discussion has an open proposal
    And I have voted on the proposal
    When I visit the discussion page
    And I edit my vote
    Then I should see new vote in the activity feed
    And I should see my new vote in the list of positions
    And I should not see my original vote in the list of positions


  Scenario: As a non-member I should not be able to vote on a proposal
    Given there is a discussion in a group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see the vote buttons