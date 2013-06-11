Feature: Display activity for a discussion
  As a user
  So I can know what's happened in a discussion
  I'd like to see an easy-to-read list of all the activity

  Scenario: Duplicate discussion activity is removed
    Given I am logged in
    And there is a discussion in a group I belong to
    When I edit a discussion description twice in quick succession
    Then I should only see one activity item in the discussion activity feed

