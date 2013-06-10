Feature: Edit Group Invitations
  In order to resent delete and view pending invitations
  As a group admin

  @javascript
  Scenario: Group Admin views pending invitations
    Given I am a signed in group admin
    And there is a pending invitation to join the group
    When I visit the group page
    And I click the pending link
    Then I should see the pending invitations for the group

  @javascript
  Scenario: Group Admin trys to view pending invitation when ther are none
    Given I am a signed in group admin
    When I visit the group page
    Then I should not see a pending link

  @javascript
  Scenario: Group Admin invites some people to join the group
    Given I am a signed in group admin
    When I visit the group page
    And I click Invite People
    And invite a couple of people to join the group
    Then the flash notice should inform me of 2 invitations being sent
    And there should be a couple of pending invitations to those people

  @javascript
  Scenario: Group Admin tries to invites people with no invites left
    Given I am a signed in group admin
    And The group has run out of invites
    When I visit the group page
    And I click Invite People
    Then I should see the no invitations page

  @javascript
  Scenario: Group Admin cancels invitation
    Given I am a signed in group admin
    And there is a pending invitation to join the group
    When I cancel the pending invitation
    Then there should be no more pending invitations
    And the flash notice should confirm the cancellation

