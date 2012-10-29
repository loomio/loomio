Feature: Email preferences page
  As a user
  In order to be informed about loomio activity in a way that is helpful and not annoying
  I want to control when loomio will send me emails

  Background:
    Given there is a user "Ben"
    And there is a group "Pals"
    And "Ben" belongs to "Pals"
    And I login as "ben@example.org"

  Scenario: User enables daily email
    When I visit the email preferences page
    And I check "user_subscribed_to_daily_activity_email"
    And I click "Update preferences"
    Then I should be subscribed to the daily actitivy email

  Scenario: User disables daily email
    Given I am subscribed to the daily activity email
    When I visit the email preferences page
    And I uncheck "user_subscribed_to_daily_activity_email"
    And I click "Update preferences"
    Then I should not be subscribed to the daily actitivy email

  Scenario: User enables 24 hour proposal close notification
    When I visit the email preferences page
    And I check "user_subscribed_to_proposal_closure_notifications"
    And I click "Update preferences"
    Then I should be subscribed to proposal closure notification emails

  Scenario: User disables 24 hour proposal close notification
    When I visit the email preferences page
    And I uncheck "user_subscribed_to_proposal_closure_notifications"
    And I click "Update preferences"
    Then I should not be subscribed to proposal closure notification emails

  Scenario: User enables group notifications
    #When I visit the email preferences page
    #And I check "Pals"
    #And I click save
    #Then I should be subscribed to group notifications about "Pals"

  Scenario: User disables group notifications
    #When I visit the email preferences page
    #And I uncheck "Pals"
    #And I click save
    #Then I should be subscribed to group notifications about "Pals"
