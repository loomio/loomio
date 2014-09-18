Feature: User votes on a motion
  As a user in order to express my position on an issue
  I must be able to vote on a motion

  Scenario: As a logged in member I should be able to vote 'yes' on a proposal
    Given I am logged in
    And there is a discussion in a group I belong to
    And the discussion has an open proposal
    When I visit the discussion page
    And I click the 'yes' vote button
    And I enter a statement
    Then I should see new vote in the activity feed
    And I should see my vote in the list of positions

  Scenario: As a logged in member I should be able to 'abstain' on a proposal
    Given I am logged in
    And there is a discussion in a group I belong to
    And the discussion has an open proposal
    When I visit the discussion page
    And I click the 'abstain' vote button
    And I enter a statement
    Then I should see new vote in the activity feed
    And I should see my vote in the list of positions

  Scenario: As a logged in member I should be able to vote 'no' on a proposal
    Given I am logged in
    And there is a discussion in a group I belong to
    And the discussion has an open proposal
    When I visit the discussion page
    And I click the 'no' vote button
    And I enter a statement
    Then I should see new vote in the activity feed
    And I should see my vote in the list of positions

  Scenario: As a logged in member I should not be able to edit my vote on a closed proposal
  	Given I am logged in
    And there is a discussion in a group I belong to
    And the discussion has an open proposal
    And I have voted on the proposal
    And the proposal has closed
    When I visit the discussion page
    Then I should not see an edit button next to my vote

  Scenario: As a non-member I should not be able to vote on a proposal
    Given there is a discussion in a public group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see the vote buttons

  Scenario: As logged out user I should be able to follow a vote link easily
    Given I am a logged out user
    And there is a discussion in a group I belong to
    And the discussion has an open proposal
    When I try to visit the vote page
    And I sign in
    Then I should be returned to the vote page

  Scenario: If I have voted and follow an email vote link I should see my existing vote
    Given I am logged in
    And there is a discussion in a group I belong to
    And the discussion has an open proposal
    And I have voted on the proposal
    And I follow a vote link from an email
    Then I should see my existing vote
