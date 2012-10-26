Feature: Proposal closing soon email
  In order to make sure that I am aware of proposals closing
  As a user
  I want to be emailed when a proposal in my group is closing

  Scenario: User in group gets email because proposal is closing
    Given there is a user "Ben"
    And "Ben" is subscribed to proposal closing soon notification emails
    And there is a group "Pals"
    And "Ben" belongs to "Pals"
    And there is a discussion "I'm Lonely" in "Pals"
    And there is a proposal "Party on Saturday" from the discussion "I'm Lonely"
    And the motion "Party on Saturday" is closing in 24 hours
    And "Ben" agreed with the proposal "Party on Saturday"
    When we run the rake task to check for closing proposals, 24 hours before it closes.
    Then "Ben" gets a proposal closing soon email
