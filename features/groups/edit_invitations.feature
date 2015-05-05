Feature: Edit Group Invitations
  As a group admin
  In order to resend delete and view pending invitations

  @javascript
  Scenario: Group Admin views pending invitations
    Given I am a signed in group admin
    And there is a pending invitation to join the group
    When I visit the group page
    And I click 'More'
    Then I should see the pending invitations for the group

  @javascript
  Scenario: Group Admin invites some people to join the group
    Given I am a signed in group admin
    When I visit the group page
    And I click 'Invite People'
    And invite a couple of people to join the group
    Then the flash notice should inform me of 2 invitations being sent
    And there should be a couple of pending invitations to those people

  @javascript
  Scenario: Group Admin cancels invitation
    Given I am a signed in group admin
    And there is a pending invitation to join the group
    When I cancel the pending invitation
    Then there should be no more pending invitations
    And the flash notice should confirm the cancellation

  Scenario: User clicks cancelled invitation link
    Given I am logged in
    And I am a member of a group
    And there is a cancelled invitation to a group
    When I click the invitation
    Then I should be told the invitation was cancelled

  Scenario: User loads unknown invitation token and is told it was not found
    Given I am logged in
    And I am a member of a group
    When I load an unknown invitation link
    Then I should be told the invitation token was not found
