Feature: User changes noise level settings
  As a Loomio User
  So that I can keep up with discussions across groups with different activity levels
  I want to be able to set levels of notifications for each group

  Background:
    Given I am a Loomio user
    And a member of a group

  Scenario: Set noise level
    When I visit the settings page
    Then I have notification settings for each group
    And I can change the notification settings
    
  Scenario: Discussion event is muted by Muted Noise
    When a new discussion is created
    And my noise level is set to "0"
    Then no notification should be received

  Scenario: Discussion event is muted by Default Noise
    When a new discussion is created
    And my noise level is set to "1"
    Then no notification should be received

  Scenario: Discussion event is notified by All Noise
    When a new discussion is created
    And my noise level is set to "2"
    Then a "new_discussion" notification is received