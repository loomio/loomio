Feature: Post a comment in a discussion
  To allow users to share their opinions
  A user must be able to post comments in a discussion

  Scenario: User enables markdown and posts a comment
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And I don't prefer markdown
    When I visit the discussion page
    And I enable markdown
    And I write and submit a comment
    Then a comment should be added to the discussion
    And the comment should format markdown characters
    And markdown should now be on by default

  Scenario: User disable markdown and posts a comment
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And I prefer markdown
    When I visit the discussion page
    And I disable markdown
    And I write and submit a comment
    Then a comment should be added to the discussion
    And the comment should not format markdown characters
    And markdown should now be off by default

  Scenario: Comments have permalinks
    Given there is a comment in a public discussion
    When I visit the discussion page
    Then there should be an anchor for the comment
    And I should see a permalink to the anchor for that comment
