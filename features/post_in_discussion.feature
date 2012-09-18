Feature: Post a comment in a discussion
  To allow users to share their opinions
  A user must be able to post comments in a discussion

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"

  Scenario: Post in discussion
    Given I am viewing a discussion titled "hello" in "demo-group"
    When I write and submit a comment
    Then a comment should be added to the discussion "hello"
