Feature: User sees the number of new comments on a discussion
  As a Loomio group member
  So that I can know if a discussion has had new comments
  I want to know how many new comments a discussion has had since I last viewed it

  Background:
    Given I am logged in
    And there is a discussion in a group I belong to

  @javascript
  Scenario: User sees new discussion has 1 unread
    When I visit the dashboard
    Then I should see that the discussion has 1 unread

  @javascript
  Scenario: User sees new discussion with new comment has 2 unread
    Given someone comments on the discussion
    When I visit the dashboard
    Then I should see that the discussion has 2 unread

  @javascript
  Scenario: User sees read discussion with unread comment has 1 unread
    Given I read the discussion when it was uncommented
    And someone comments on the discussion
    When I visit the dashboard
    Then I should see that the discussion has 1 unread
