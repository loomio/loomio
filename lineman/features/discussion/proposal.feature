Feature: Proposals
  Scenario: Starting a proposal
    Given I am signed in, viewing a new discussion
    When I click 'Start a proposal'
    And I fill in and submit the proposal form
    Then I'll see the new proposal discussion item
    And the proposal should be running

  Scenario: Extending a proposal
  Scenario: Closing a proposal
