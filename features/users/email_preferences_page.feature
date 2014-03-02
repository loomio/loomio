Feature: Email preferences page
  As a user
  In order to be informed about loomio activity in a way that is helpful and not annoying
  I want to control when loomio will send me emails

  Background:
    Given there is a user "Ben"
    And there is a group "Pals"
    And "Ben" belongs to "Pals"
    And I login as "ben@example.org"
    And I am testing all activity summary email beta feature

  Scenario: User enables activity summary email by clicking a day of the week
    When I visit the email preferences page
    And I click on Monday
    And I click on Wednesday
    And I select the time of day
    And I click "Update preferences"
    Then I should be subscribed to the activity summary email

  Scenario: User disables activity summary email by desellecting all days of the week
    Given I am subscribed to the activity summary email
    When I visit the email preferences page
    And I unselect the days to receive the summary email
    And I click "Update preferences"
    Then I should not be subscribed to the activity summary email

  Scenario: User enables 24 hour proposal close notification
    When I visit the email preferences page
    And I check "email_preference_subscribed_to_proposal_closure_notifications"
    And I click "Update preferences"
    Then I should be subscribed to proposal closure notification emails

  Scenario: User disables 24 hour proposal close notification
    When I visit the email preferences page
    And I uncheck "email_preference_subscribed_to_proposal_closure_notifications"
    And I click "Update preferences"
    Then I should not be subscribed to proposal closure notification emails

  Scenario: User enables mention email notifications
    Given I am not subscribed to mention email notifications
    When I visit the email preferences page
    And I check "email_preference_subscribed_to_mention_notifications"
    And I click "Update preferences"
    Then I should be subscribed to mention notifications

  Scenario: User disables mention email notifications
    Given I am subscribed to mention email notifications
    When I visit the email preferences page
    And I uncheck "email_preference_subscribed_to_mention_notifications"
    And I click "Update preferences"
    Then I should not be subscribed to mention notifications

  Scenario: User enables group notifications
    When I visit the email preferences page
    And I check "Pals"
    And I click "Update preferences"
    Then I should be subscribed to group notifications about "Pals"

  Scenario: User disables group notifications
    Given I am subscribed to group notifications about "Pals"
    When I visit the email preferences page
    And I uncheck "Pals"
    And I click "Update preferences"
    Then I should not be subscribed to group notifications about "Pals"
