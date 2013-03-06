Feature: Like post
  In order for users to show their appreciation for other users' posts
  A user must be able to like a post

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"

  Scenario: Like post
    Given I am viewing a discussion titled "hello" in "demo-group"
    And I am on the discussion page
    When I write and submit a comment
    And I click the like button on a post
    Then a post should be liked by "furry@example.com"
