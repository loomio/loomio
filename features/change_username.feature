Feature: Change Username
  In order to allow users to feel at home
  we allow them to change their usernames.

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"

  Scenario: Successful Change
    When I am on the settings page
    And I enter my desired username
    And the username is not taken
    Then my username is changed

  Scenario: Change to original username
    When I am on the settings page
    And I enter my current username
    Then my username stays the same

  Scenario: Attempt to change to taken username
    When I am on the settings page
    And I enter my desired username
    And the username is taken
    Then my username is not changed
