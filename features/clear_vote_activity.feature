Feature: Clear vote activity
  In order to get a summary of a proposal's activity from the Home or Group page
  A user must be able to click the mini pie graph on a discussion in the discussion list

  Scenario: Logged in user views a discussion's proposal activity from the group page
    Given there is a discussion in a group
    And the discussion has an open proposal
    And there is proposal activity on the discussion
    And I am logged in
    When I visit the group page
    And I click on the mini-pie graph for the discussion
    Then I should see a summary of the proposal's activity
    And the proposal activity count should clear for that discussion

  Scenario: Logged in user views a discussion's proposal activity from the group page multple times
    Given there is a discussion in a group
    And the discussion has an open proposal
    And there is proposal activity on the discussion
    And I am logged in
    When I visit the group page
    And I click on the mini-pie graph for the discussion
    And There is futher activity since I clicked the graph
    And I click on the mini-pie graph for the discussion
    Then I should only see the new activity for the proposal
    And the proposal activity count should clear for that discussion

  Scenario: Logged in user sees a discussion's proposal activity from the group page, visits the discussion then returns to the group page
    Given there is a discussion in a group
    And the discussion has an open proposal
    And there is proposal activity on the discussion
    And I am logged in
    When I visit the group page
    And I see the discussion's proposal activity count
    And I visit the discussion page
    And I re-visit the group page
    Then I should not see proposal activity for that discussion

  Scenario: Logged out user views a discussion's proposal activity from the group page
    Given there is a discussion in a group
    And the discussion has an open proposal
    And I see proposal activity on the discussion
    When I visit the group page
    And I click on the mini-pie graph for the discussion
    Then I should see a summary of the proposal's activity
    And I should still see the proposal activity count for that discussion
