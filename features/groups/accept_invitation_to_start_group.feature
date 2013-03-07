Feature: Group admin accepts invitation to start a Loomio group
  As a future Loomio group admin
  So that I can make decisions with my group on Loomio
  I want accept my invitation to start a group on Loomio

  Scenario: Group admin (without existing account) accepts invitation to start a Loomio group
    Given I have requested to start a loomio group
    And the group request has been approved
    When I open the email sent to me
    And I click the invitation link to start a new group
    And I choose to create an account
    And I fill in and submit the new user form
    Then I should become the admin of the group
    And the group request should be marked as accepted
    And I should be taken to the group page

  Scenario: Logged-out group admin accepts invitation to start a Loomio group
    Given I have requested to start a loomio group
    And the group request has been approved
    When I open the email sent to me
    And I click the invitation link to start a new group
    And I choose to log in and then I submit the login form
    Then I should become the admin of the group
    And the group request should be marked as accepted
    And I should be taken to the group page

  Scenario: Logged-in group admin accepts invitation to start a Loomio group
    Given I am logged in
    And I have requested to start a loomio group
    And the group request has been approved
    When I open the email sent to me
    And I click the invitation link to start a new group
    Then I should become the admin of the group
    And the group request should be marked as accepted
    And I should be taken to the group page

  Scenario: Group admin tries to accept an invitation to start a Loomio group with an incorrect token
    Given I have requested to start a loomio group
    And the group request has been approved
    When I try to start the group with an incorrect token
    Then I should be notified the link is invalid

  Scenario: Group admin tries to accept an invitation to start a Loomio group that has already been accepted
    Given I have requested to start a loomio group
    And the group request has been accepted
    When I open the email sent to me
    And I click the invitation link to start a new group
    Then I should be notified the invitation has already been accepted
