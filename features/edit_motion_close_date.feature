Feature: Admin/author edits a proposal close date
  As a Loomio group admin or an authour of a proposal
  I want to be able to edit the close date of a proposal

Scenario: Admin extends a proposal close date
  Given I am an admin of a group with a discussion
  And the discussion has a proposal
  And the proposal is currently open
  When I click the 'edit close date' button
  And I select the new close date
  Then The proposal close date should be updated