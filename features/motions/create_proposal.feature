Feature: User creates proposal
  As a member of a group
  So that we can make decisions
  I want to be able to create proposals

  Background:
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group

  Scenario: Group member creates proposal
    When I visit the discussion page
    And I click "Create a proposal"
    Then I should see the create proposal page
    And I fill in the proposal details and submit the form
    Then a new proposal should be created
    And I should see the proposal details
