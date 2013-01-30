Feature: Admin/author closes a proposal
  As a Loomio group admin or an authour of a proposal
  So that we can move the proposal into action or create another proposal
  I want to be able to close a proposal

  Scenario: Admin closes a proposal
    Given I am logged in
    And I am an admin of a group
    And the group has a discussion with a decision
    When I visit the discussion page
    # And I take a screenshot
    And I click the 'Close proposal' button
    And I confirm the action
    Then I should see the proposal in the list of previous proposals

  Scenario: User tries to close a proposal
    Given there is a discussion in a public group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see a link to close the proposal