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
    And I reload the dashboard
    Then I should not see the announcement

  Scenario: User does not see announcements when starting group
    Given there is an announcement
    When I go to start a new group from the navbar
    Then I should not see the announcement
    When I fill in the group name and submit the form
    And I recieve an email with an invitation link
    When I click the invitation link
    Then I should not see the announcement
