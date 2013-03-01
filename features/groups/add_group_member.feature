Feature: Admin adds member to group
  As an admin of a group
  So that we can have discussions and make decisions
  I want to add other users to my group

  Background:
    Given I am logged in
    And I am an admin of a group
    Given "Ben" is an existing user
    And no emails have been sent

  Scenario: Admin adds existing Loomio user to group
    When I visit the group page
    And I invite "ben@example.org" to the group
    Then they should be added to the group
    And they should receive an email with subject "You've been added to a group"
    When they open the email
    And they click the first link in the email
    Then they should be taken to the group page

  Scenario: Admin attempts to add existing group member
    Given "Hannah" is a member of the group
    When I visit the group page
    And I invite "hannah@example.org" to the group
    Then I should be notified that they are already a member

  Scenario: Admin invites non-existing Loomio user to group
    When I visit the group page
    And I invite "newuser@example.org" to the group
    And I should be notified that they have been invited

  Scenario: Admin attempts to add invalid email to group
    When I visit the group page
    And I invite "Hannah <Hannah@example.org>" to the group
    Then I should be notified that the email address is invalid
    And "Hannah <Hannah@example.org>" should not be a member of the group

  Scenario: Admin attempts to add member without email
    When I visit the group page
    And I invite "Hannah" to the group
    Then I should be notified that the email address is invalid
    And "Hannah" should not be a member of the group
