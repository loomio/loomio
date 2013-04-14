Feature: New user views discussions

  Scenario: User without any groups views dashboard
    Given I am logged in
    When I visit the dashboard
    Then I should see "Request New Group"

  Scenario: New user belonging to new group views dashboard
    Given I am logged in
    And I am a member of a public group
    And the group has a discussion with a decision
    When I visit the dashboard
    Then I should see the decision
    And I should see an empty discussion list

  Scenario: New user belonging to new group views group
    Given I am logged in
    And I am a member of a public group
    And the group has a discussion with a decision
    When I visit the group page
    Then I should see the decision
    And I should see an empty discussion list

  Scenario: New user views empty sub-group
    Given I am logged in
    And I am a member of a public sub-group
    When I visit the sub-group page
    Then I should see "This group does not have any discussions yet."
