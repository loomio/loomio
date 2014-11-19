Feature: Proposals
  Scenario: Starting a proposal
    Given I am signed in, viewing a new discussion
    When I click 'Start a proposal'
    And I fill in and submit the proposal form
    Then I'll see the new proposal discussion item
    And the proposal should be running

  Scenario: Voting with statement
    Given I am signed in, viewing a discussion with a proposal
    When I click the agree button and enter a statement
    Then I should see my vote and statement

  Scenario: Extending the close date

  Scenario: Closing and setting outcome

