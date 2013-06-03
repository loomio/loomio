Feature: Cancel invitation
  In order to cancel an invitation
  There needs to be a way to mark an invitation as cancelled
  and ensure that when the invitaiton is used, the user knows what's going on

  Scenario: Group coordinator cancels an invitation
    Given there is a pending invitation to a group
    When the group coordinator cancels the invitation
    Then the invitation should be cancelled

  Scenario: Someone clicks cancelled invitation link
    Given there is a cancelled invitation to a group
    When the user clicks the invitation
    Then they should be told the invitaiton was cancelled
