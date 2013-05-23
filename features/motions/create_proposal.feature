Feature: User creates proposal
  As a member of a group
  So that we can make decisions
  I want to be able to create proposals

  Background:
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And my time zone setting has been set

  Scenario: Group member creates proposal
    When I visit the discussion page
    And I click "Create new proposal"
    Then I should see the create proposal page
    And the time zone should match my time zone setting
    And fill in the proposal details and submit the form
    Then a new proposal is created
    And I should see the proposal details

  Scenario: Members get emailed when a proposal is created
   Given "Ben" is a member of the group
    And "Hannah" is a member of the group
    And "newuser@example.org" has been invited to the group but has not accepted
    And no emails have been sent
    And "Ben" has chosen to be emailed about new discussions and decisions for the group
    And "Hannah" has chosen not to be emailed about new discussions and decisions for the group
    When I visit the discussion page
    And I click "Create new proposal"
    And fill in the proposal details and submit the form
    Then "ben@example.org" should have an email
    When "ben@example.org" opens the email
    And clicking the link in the email should take him to the proposal
    Then "hannah@example.org" should receive no email
    And "newuser@example.org" should receive no email
