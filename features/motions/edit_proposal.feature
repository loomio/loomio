Feature: Edit Proposal
  As a Loomio Admin or proposal author
  So that I can correct spelling mistakes or things my cat typed
  I want to edit a proposal

  Scenario: Admin edits proposal
    Given I am the logged in admin of a group
    And there is an open proposal in the group
    When I update the proposal
    Then the proposal should be updated
