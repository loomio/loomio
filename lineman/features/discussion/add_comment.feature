Feature: Add a comment to a discussion

  Scenario: Signed in user adds a comment
    Given I am signed in, viewing a discussion
    When I add a comment to the discussion
    Then I should see the comment has been appended to the discussion
