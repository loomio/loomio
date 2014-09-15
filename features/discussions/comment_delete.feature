Feature: User deletes post
  As a user
  So that I can remove a comment I no longer wish to be visable in the discussion
  I want to be able to delete my comment

  @javascript
  Scenario: User deletes their own comment
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And I am on the discussion page
    And I write and submit a comment
    When I click the delete button on a post
    Then I should no longer see the post in the discussion
    And I should be told the comment was deleted

 Scenario: User tries to delete another user's comment
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And the discussion has a comment
    When I am on the discussion page
    Then I should not see the delete link on another users comment
