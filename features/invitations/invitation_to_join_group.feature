Feature: Invitation to join group
  As a coordinator
  I want to invite new users to my group
  So that I can have the right people in my discussions

  @javascript
  Scenario: Group Admin invites multiple users to join a group
    Given I am a group admin
    When I invite bill and jane to our group
    Then bill and jane should both have invitations to join

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
  Scenario: New user accepts invitiation to join a group
    Given I am invited to join a group
    When I accept my invitation via email
    Then I should see the signup form prepopulated with my email address
    When I sign up as a new user
    Then I should be a member of the group

  @javascript
  Scenario: Signed out user accepts invitiation to join a group
    Given I am a logged out who is invited to join a group
    When I accept my invitation via email
    Then I should see the sign in form prepopulated with my email address
    When I fill in the form
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

  #@javascript
  #Scenario: Signed out user refollows their invitation link
  #  Given I am not logged in
  #  When I follow an invitation link I have already used
  #  Then I should be told the invitation link has already been used

  @javascript
  Scenario: Subgroup admin invites people to subgroup
    Given I am logged in
    And I am an admin of a group
    And I am an admin of a subgroup invitable by admins
    And "David" is a member of the group
    When I visit the subgroup page
    And I click invite people
    And I enter "new@user.com" in the invitations field
    And I select "David" from the list of members
    And I confirm the selection
    Then "new@user.com" should be invited to join the subgroup
    And I should see "David" as a member of the subgroup
    And "David" should receive a notification that they have been added

  @javascript
  Scenario: Subgroup member cannot add members to a subgroup invitable by admins
    Given I am logged in
    And I am a member of a group
    And I am a member of a subgroup invitable by admins
    When I visit the subgroup page
    Then I should not see the add member button

  # @javascript
  # Scenario: Group Admin invites new user to join discussion
  #   Given I am a group admin
  #   When I visit a discussion page
  #   And I click "Invite people"
  #   And I invite "new@user.com" to join the discussion
  #   Then "new@user.com" should get an invitation to join the discussion

  # @javascript
  # Scenario: New user accepts invitation to join discussion
  #   Given I am invited to join a discussion
  #   When I accept my invitation via email
  #   Then I should see the signup form prepopulated with my email address
  #   When I sign up as a new user
  #   Then I should be a member of the group
  #   And I should be redirected to the discussion page
