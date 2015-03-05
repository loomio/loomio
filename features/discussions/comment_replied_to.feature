Feature: Comment replied to
  As a user
  So that I can communicate effectively with people participating in a discussion
  I want to be notified when someone replies to one of my comments

@javascript
  Scenario: User is notified when someone replies to their comment
    Given I am logged in
    And there is a discussion in a group I belong to
    And I have posted a comment in the discussion
    When someone replies to my comment
    Then I should receive an email notification
    And the email should tell me who replied to my comment, and in which discussion
