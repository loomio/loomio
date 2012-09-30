Feature: Noise levels
  In order to control noise levels
  Users must be able to set noise for a group

  Background:
    Given I am logged in
    And a member of a group
    With three users with noise levels set

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

