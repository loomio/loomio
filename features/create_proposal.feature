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
    And I click "Create new proposal"
    And fill in the proposal details and submit the form
    Then a new proposal is created

  Scenario: Members get emailed when a proposal is created
   Given "Ben" is a member of the group
    And "Hannah" is a member of the group
    And no emails have been sent
    And "Ben" has chosen to be emailed about new discussions and decisions for the group
    And "Hannah" has chosen not to be emailed about new discussions and decisions for the group
    When I visit the discussion page
    And I click "Create new proposal"
    And fill in the proposal details and submit the form
    Then "Ben" should be emailed about the new proposal
    And clicking the link in the email should take him to the proposal
    And "Hannah" should not be emailed about the new proposal
    And the email should tell him when the proposal closes
