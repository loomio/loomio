Feature: Create discussion
  To allow users to share their opinions
  A user must be able to start a discussion

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"

  Scenario: Create discussion from group page
    When I visit the group page for "demo-group"
    When I visit the create discussion page
    And fill in discussion details
    Then a discussion should be created

  Scenario: Create discussion from dashboard
    When I visit the dashboard
    When I visit the create discussion page
    And I select "demo-group" from the groups dropdown
    And fill in discussion details
    Then a discussion should be created
