Feature: Edit Comment

  Background:
    Given I am logged in
    And I belong to a group with a discussion

  Scenario: User edits their comment
    Given I have a comment on the discussion
    When I edit my comment
    Then I should see my comment has updated in the discussion

  Scenario: User views edited comment diff
    Given there is an edited comment in the discussion
    When I view the history of that comment
    Then I should see the old and new versions


