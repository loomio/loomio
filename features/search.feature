Feature: Search discussions and comments
  In order to find a particular loomio disucssion based on user input
  As a user
  I need to search discussions

  Background:
    Given I am logged in and belong to a group

  Scenario: User searches for discussion by title
    Given there is a discussion in my group titled "Pigs that fly"
    When I search for "pigs"
    Then I should see a discussion with the title "Pigs that fly"

  Scenario: User does not see results for discussions outside their groups
    Given there is a discussion in another group titled "Pigs that fly"
    When I search for "pigs"
    Then I should not see the discussion with the title "Pigs that fly"

  Scenario: User searches for discussion by description
    Given there is a discussion with description "Hogs on a plane"
    When I search for "hogs"
    Then I should see the discussion with the description "Hogs on a plane"
