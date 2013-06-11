Feature: Invitation to join group
  In order to get users into a group
  We need to send them invitations

  @javascript
  Scenario: Group Admin invites new user to join a group
    Given there is a group
    And I am an admin of that group
    And I am on the group show page
    When I click Invite people from the members box
    And enter "jim@jam.com" into the recipients
    And fill in the message body
    And click Send Invitations
    Then "jim@jam.com" should get an invitation to join the group
    And I should be directed to the group page

  Scenario: New user accepts invitiation to join a group
    Given there is a group
    And an invitation to join the group has been sent to "jim@jam.com"
    When I open the email and click the accept invitation link
    And I sign up as a new user
    Then I should be a member of the group
    And I should be redirected to the group page

  Scenario: Existing user accepts invitiation to join a group
    Given there is a group
    And an existing user with email "jim@jam.com"
    And an invitation to join the group has been sent to "jim@jam.com"
    When I open the email and click the accept invitation link
    And I click the link to the sign in form
    And I sign in as "jim@jam.com"
    Then I should be a member of the group
    And I should be redirected to the group page

  Scenario: Signed in user accepts invitiation to join a group
    Given there is a group
    And I am signed in as "jim@jam.com"
    And an invitation to join the group has been sent to "jim@jam.com"
    When I open the email and click the accept invitation link
    Then I should be a member of the group
    And I should be redirected to the group page

  Scenario: Signed in user refollows their invitation link
    Given there is a group
    And I am signed in as "jim@jam.com"
    And I follow an invitation link I have already used
    When I follow the invitation link
    Then I should be redirected to the group page

  Scenario: Signed out user refollows their invitation link
    Given there is a group
    And I am a user but i am not signed in
    And I follow an invitation link I have already used
    When I follow the invitation link
    Then I should be told the invitation link has already been used
