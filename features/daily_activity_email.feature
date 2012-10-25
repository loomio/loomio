Feature: Daily activity email
  In order to stay informed across all my loomio groups
  I want to receive a summary of proposal and discussions in my email

  Scenario:
    Given there is a user "Ben"
    Given there is a group "Pals"
    And "Ben" belongs to "Pals"
    And there is a discussion "I'm Lonely" in "Pals"
    And there is a proposal "Party on Saturday" from the discussion "I'm Lonely"
    When we send the daily activity email
    Then "Ben" should get emailed
    And that email should have the discussion "I'm Lonely"
    And that email should have the proposal "Party on Saturday"
