Feature: Admin/author closes a proposal
  As a Loomio group admin or an authour of a proposal
  So that we can move the proposal into action or create another proposal
  I want to be able to close a proposal

Scenario: Admin closes proposal
  Given there is a discussion in a group
  And I am an admin of this group
  And the discussion has a proposal
  And the proposal is currently open
  And I am logged in
  When I visit the discussion page
  And I click the 'Close proposal' button
  And I confirm this action
  Then I should see the proposal in the list of previous proposals

  Scenario: User tries to close a proposal
  Given there is a discussion in a group
  And the discussion has a proposal
  When I visit the discussion page
  Then I should not see a link to close the proposal