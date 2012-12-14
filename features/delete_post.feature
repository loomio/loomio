Feature: Delete post
  If a user no longer wishes a post of theirs to be visable in the discussion
  A user must be able to delete a post

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"

  Scenario: Delete post
    Given I am viewing a discussion titled "hello" in "demo-group"
    And I am on the discussion page
    And I write and submit a comment
    When I click the delete button on a post
    And I accept the popup to confirm
    Then I should no longer see the post in the discussion