Feature: Daily activity email
  In order to stay informed across all my loomio groups
  I want to receive a summary of proposal and discussions in my email

  Scenario: Ben is sent a daily activity email
    Given there is a user "Ben"
    And "Ben" is subscribed to daily activity emails
    Given there is a group "Pals"
    And "Ben" belongs to "Pals"
    And there is a discussion "I'm Lonely" in "Pals"
    And there is a proposal "Party on Saturday" from the discussion "I'm Lonely"
    When we send the daily activity email
    Then "Ben" should get emailed
    And that email should have the discussion "I'm Lonely"
    And that email should have the proposal "Party on Saturday"

  Scenario: Ben is not sent a daily activity email
    Given there is a user "Ben"
    And "Ben" is subscribed to daily activity emails
    Given there is a group "Pals"
    And "Ben" belongs to "Pals"
    # Note there is no discussions or motions.. so there should be no email
    When we send the daily activity email
    Then "Ben" should not get emailed

  Scenario: User clicks unsubscribe link in email to unsubscribe
    # note ben is not logged in
    Given there is a user "Ben"
    And "Ben" is subscribed to daily activity emails
    Given there is a group "Pals"
    And "Ben" belongs to "Pals"
    And there is a discussion "I'm Lonely" in "Pals"
    When we send the daily activity email
    Then there should be an unsubscribe link in it
    When ben clicks the unsubscribe link
    Then he should be taken to the email preferences page


