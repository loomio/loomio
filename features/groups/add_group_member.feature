Feature: Member adds user to group
  As a member of a group
  So that we can have discussions and make decisions
  I want to add other users to my group

  Background:
    Given I am logged in

  Scenario: Member invites a non-existing Loomio user to a group invitable by members
    Given I am a member of a group invitable by members
    When I visit the group page
    And I invite "newuser@example.org" to the group
    And I should be notified that they have been invited
    When I visit the group page
    Then I should see "newuser@example.org" listed in the invited list

  Scenario: Member attempts to add a non-existing Loomio user to a group invitable by admins
    Given "newuser@example.org" has been invited to the group
    And I am a member of a group
    And  the group is invitable by admins
    When I visit the group page
    Then I should not see the add member button
    And I should not see the invited user list

  Scenario: Admin adds existing Loomio user to group
    Given I am an admin of a group
    And "Ben" is an existing user
    And no emails have been sent
    When I visit the group page
    And I invite "ben@example.org" to the group
    Then they should be added to the group
    And they should receive an email with subject "You've been added to a group"
    When they open the email
    And they click the first link in the email
    Then they should be taken to the group page

  Scenario: Admin invites non-existing Loomio user to group
    Given I am an admin of a group
    When I visit the group page
    And I invite "newuser@example.org" to the group
    And I should be notified that they have been invited
    When I visit the group page
    Then I should see "newuser@example.org" listed in the invited list

  Scenario: Admin attempts to add existing group member
    Given I am an admin of a group
    And "Hannah" is a member of the group
    When I visit the group page
    And I invite "hannah@example.org" to the group
    Then I should be notified that they are already a member

  Scenario: Admin attempts to add invalid email to group
    Given I am an admin of a group
    When I visit the group page
    And I invite "Hannah <Hannah@example.org>" to the group
    Then I should be notified that the email address is invalid
    And "Hannah <Hannah@example.org>" should not be a member of the group

  Scenario: Admin attempts to add member without email
    Given I am an admin of a group
    When I visit the group page
    And I invite "Hannah" to the group
    Then I should be notified that the email address is invalid
    And "Hannah" should not be a member of the group
