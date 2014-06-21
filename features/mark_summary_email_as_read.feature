Feature: Mark summary email as read
  So that I can read my new content from my email, and the inbox will know that I've read it
  I want to be able to mark the summary email as read

  Scenario: Logged out user marks summary email as read
    Given I am a logged out user with an unread discussion
    When I mark the email as read
    Then the discussion should be marked as read when the email was generated
