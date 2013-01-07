Feature: Post a comment in a discussion
  To allow users to share their opinions
  A user must be able to post comments in a discussion

  Scenario: Post in discussion
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    When I visit the discussion page
    And I write and submit a comment
    Then a comment should be added to the discussion
