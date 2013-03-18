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
    Then I should be notified that they have been invited
    And I should see "newuser@example.org" listed in the invited list

  Scenario: Member attempts to add a non-existing Loomio user to a group invitable by admins
    Given I am a member of a group
    And "newuser@example.org" has been invited to the group
    And the group is invitable by admins
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


  Scenario: Subgroup member adds members to subgroup
    Given I am a member of a group
    And I am a member of a subgroup invitable by members
    And "David" is a member of the group
    And "Joe" is a member of the group
    When I visit the subgroup page
    And I click add new member
    And I select "David" from the list of members
    And I select "Joe" from the list of members
    And I click "Invite members"
    Then I should see "David" as a member of the subgroup
    And I should see "Joe" as a member of the subgroup

  Scenario: Subgroup member cannot add members to a subgroup invitable by admins
    Given I am a member of a group
    And I am a member of a subgroup invitable by admins
    When I visit the subgroup page
    Then I should not see the add member button

  Scenario: Member adds a user invited to the parent group to a subgroup invitable by members
    Given I am a member of a group
    And "david@example.org" has been invited to the group but has not accepted
    And I am a member of a subgroup invitable by members
    When I visit the subgroup page
    And I click add new member
    And I select "david@example.org" from the list of members
    And I click "Invite members"
    Then I should see "david@example.org" as an invited user of the subgroup

  Scenario: Group member cannot see invited users when adding subgroup members (if parent group is invitable by admins)
    Given I am a member of a group
    And the group is invitable by admins
    And "david@example.org" has been invited to the group but has not accepted
    And "Joe" is a member of the group
    And I am a member of a subgroup invitable by members
    When I visit the subgroup page
    And I click add new member
    Then I should not see "david@example.org" in the list
    But I should see "Joe" in the list

  Scenario: Admin adds a user invited to the parent group to a subgroup invitable by admins
    Given I am a member of a group
    And "david@example.org" has been invited to the group but has not accepted
    And I am an admin of a subgroup invitable by admins
    When I visit the subgroup page
    And I click add new member
    Then I should see "david@example.org" in the list
    When I select "david@example.org" from the list of members
    And I click "Invite members"
    Then I should see "david@example.org" as an invited user of the subgroup
