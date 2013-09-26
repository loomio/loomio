Feature: Post a comment in a discussion
  To allow users to share their opinions
  A user must be able to post comments in a discussion

  @javascript
  Scenario: User posts comment
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    When I visit the discussion page
    And I write and submit a comment
    Then a comment should be added to the discussion
    And the comment should format markdown characters
    And the comment should autolink links

  @javascript
  Scenario: Discussion activity clears when user posts comment
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    When I visit the discussion page
    And I write and submit a comment
    And I visit the group page
    Then I should not see new activity for the discussion

  Scenario: Comments have permalinks
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And the discussion has a comment
    When I visit the discussion page
    Then there should be an anchor for the comment
    And I should see a permalink to the anchor for that comment
