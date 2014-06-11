Feature: Admin/author closes a proposal
  As a Loomio group admin or an authour of a proposal
  So that we can move the proposal into action or create another proposal
  I want to be able to close a proposal

  @javascript
  Scenario: Admin closes a proposal
    Given I am the logged in admin of a group
    And there is an open proposal in the group
    When I close the proposal via the edit form
    Then I should see the proposal in the list of previous proposals
