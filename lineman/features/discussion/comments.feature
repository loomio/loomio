Feature: Comments in a discussion

  Background:
    Given I am signed in and viewing a discussion

  Scenario: Signed in user adds a comment
    When I add a comment to the discussion
    Then I should see the comment has been appended to the discussion

  Scenario: User likes a comment
    Given there is a comment on the discussion
    When I click like on the comment
    Then I should see that I have liked the comment
