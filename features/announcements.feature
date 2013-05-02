Feature: Announcements
  Yeyeayeya

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"

  Scenario: I see an active announcement
    Given there is an announcement
    When I load the dashboard
    Then I should see the announcement

  Scenario: I dismiss an announcement
    Given there is an announcement
    When I load the dashboard
    And I dismiss the announcement
    And I reload the page
    Then I should not see the announcement

