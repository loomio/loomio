Feature: Invitation to join group
  In order to get users into a group
  We need to send them invitations

  @javascript
  Scenario: Group Admin invites new user to join a group
    Given I am a group admin
    When I invite "new@user.com" to our group
    Then "new@user.com" should get an invitation to join the group

  @javascript
  Scenario: Inviting existing user auto adds them to the group
    Given I am a group admin
    And there is a user called "Jim Jam" with email "jim@jam.com"
    When I invite "jim@jam.com" to our group
    Then "Jim Jam" should be auto-added to the group
    And "Jim Jam" should receive a notification that they have been added
    And "jim@jam.com" should receive an email

  @javascript
  Scenario: Coordinator invites existing group member
    Given I am a group admin
    And there is a group member with email "tony@tires.com"
    When I invite "tony@tires.com" to our group
    Then I should be told "tony" is already a member

  @javascript
  Scenario: New user accepts invitiation to join a group
    Given I am invited to join a group
    When I accept my invitation via email
    Then I should see the signup form prepopulated with my email address
    When I sign up as a new user
    Then I should be a member of the group

  Scenario: Signed in user accepts invitiation to join a group with different email address
    Given I am logged in
    And I am invited at "anotheremail@address.com" to join a group
    When I accept my invitation via email
    Then I should be a member of the group

  @javascript
  Scenario: Signed in user refollows their invitation link
    Given I am logged in
    When I click an invitation link I have already used
    Then I should be redirected to the group page

  Scenario: Signed out user refollows their invitation link
    Given I am not logged in
    When I follow an invitation link I have already used
    Then I should be told the invitation link has already been used
