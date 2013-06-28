Feature: Inbox Preferences
  In order to change the behaviour of the inbox
  as a user
  I want to configure my inbox preferences

  Background:
    Given I am logged in
    And I belong to 2 groups

  Scenario: User views inbox preferences
    When I visit the inbox preferences
    Then I should see the groups I belong to
