Feature: Post a comment in a discussion
  To allow users to share their opinions
  A user must be able to post comments in a discussion

  Scenario: User posts a comment with markdown enabled
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And I prefer markdown
    When I visit the discussion page
    And I write and submit a comment
    Then a comment should be added to the discussion
    And the comment should format markdown characters

  Scenario: User posts a comment with markdown disabled
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And I don't prefer markdown
    When I visit the discussion page
    And I write and submit a comment
    Then a comment should be added to the discussion
    And the comment should not format markdown characters

  Scenario: User changes markdown preference to enabled, posts comment
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And I don't prefer markdown
    When I visit the discussion page
    And I enable markdown
    And I write and submit a comment
    Then a comment should be added to the discussion
    And the comment should format markdown characters
    And markdown preference should show enabled

  Scenario: User changes markdown prefernece to disabled, posts commetn
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And I prefer markdown
    When I visit the discussion page
    And I disable markdown
    And I write and submit a comment
    Then a comment should be added to the discussion
    And the comment should not format markdown characters
    And markdown preference should show disabled
