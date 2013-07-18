Feature: Search discussions and proposals
  In order to find a particular loomio disucssion or proposal based on user input
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

  Scenario: User searches for motion by title
    Given there is a motion in my group titled "Figs that cry"
    When I search for "Figs"
    Then I should see a motion with the title "Figs that cry"

  Scenario: User does not see results for motion outside their groups
    Given there is a motion in another group titled "Figs that cry"
    When I search for "Figs"
    Then I should not see the motion with the title "Figs that cry"

  Scenario: User searches for motion by description
    Given there is a motion with description "Dogs in a lane"
    When I search for "Dogs"
    Then I should see the motion with the description "Dogs in a lane"
