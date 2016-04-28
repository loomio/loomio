Feature: Following Logic

Background:
  Given I am logged in
  And I am an admin of a group

  Scenario: New discussion in group I belong to
    When someone else creates a discussion in my group
    Then I should be following the discussion

  Scenario: New discussion in followed group
    Given I am autofollowing new discussions in my group
    When someone else creates a discussion in my group
    Then I should be following the discussion

  Scenario: I create a discussion and am following it
    When I create a discussion in my group
    Then I should be following the discussion

  Scenario: I comment in a discussion
    Given there is a discussion I am not following
    When I comment in the discussion
    Then I should be following the discussion

  Scenario: I like a comment in a discussion
    Given there is a discussion I am not following
    When I like a comment in the discussion
    Then I should be following the discussion

  Scenario: I update the discussion
    Given there is a discussion I am not following
    And I update the title
    Then I should be following the discussion

  Scenario: View followed discussions
    Given I create a discussion in my group
    Then my followed threads should include the discussion

  Scenario: View followed group threads
    Given I am following by default in a group
    When there is a discussion created by someone in the group
    Then my followed threads should include the discussion
