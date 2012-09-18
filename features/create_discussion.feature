Feature: Create discussion
  To allow users to share their opinions
  A user must be able to start a discussion

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"

  Scenario: Create discusiion
    When I visit the group page for "demo-group"
    When I visit the create discussion page
    And fill in discussion details
    Then a discussion should be created
