Feature: User sees pagination on long discussions
  As a Loomio user
  I want to have paginated content
  So the pages don't take too long to load

  Background:
    Given I am logged in
    And I belong to a group with a discussion

  @javascript
  Scenario: See pagination
    Given a discussion has over 50 posts
    When I visit the discussion page
    And I click the pagination navigation
    Then I should see more posts

  Scenario: Don't see pagination
    Given a discussion has less than 50 posts
    When I visit the discussion page
    Then I should not see the pagination navigation
