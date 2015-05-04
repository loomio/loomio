Feature: Rate limiting object creation
  In order to prevent unnecessary database growth and bot span
  Excessive create requests should be rejected

  Background:
    Given I am logged in and belong to a group

  Scenario: User searches for discussion by title
    Given there is a discussion in my group titled "Pigs that fly"
    When I visit the discussion page
    And I attempt to create 30 comments in the discussion
    Then I should see a rate limiting error page