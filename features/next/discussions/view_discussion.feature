Feature: Viewing A Discussion

  Background:
    Given I am logged in
    And there is a discussion in a group I belong to
    And the discussion has a comment

  @javascript
  Scenario: User views a discussion
    When I am looking the mobile version of the discussion
    Then I should see the discussion title, context, and author
    And I should see the comments


