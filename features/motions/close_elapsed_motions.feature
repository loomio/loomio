Feature: Close lapsed motions
  As a computer running loomio
  In order to close motions at the time they are scheduled to close
  I close lapsed motions

  Scenario:
    Given there is an unclosed motion with closing_at in the past
    When I close lapsed motions
    Then the motion should be closed
