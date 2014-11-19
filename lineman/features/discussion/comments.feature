Feature: Comments in a discussion

  Scenario: User adds a comment
    Given I am signed in, viewing a new discussion
    When I add a comment to the discussion
    Then I should see the comment has been appended to the discussion

  Scenario: User likes a comment
    Given I am signed in, viewing a discussion with a comment
    When I click like on the comment
    Then the like button should say 'Unlike'
    And I should see that I have liked the comment

  Scenario: User replies to a comment
    Given I am signed in, viewing a discussion with a comment
    When I reply to the comment
    Then I should see my reply comment in the discussion
