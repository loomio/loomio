Feature: Delete post
  User no longer wishes their post to be visable in the discussion
  A user must be able to delete a post

  Scenario: Delete post
    Given I am logged in
    And I am an admin of a group with a discussion
    And I am on the discussion page
    And I write and submit a comment
    When I click the delete button on a post
    And I accept the popup to confirm
    Then I should no longer see the post in the discussion