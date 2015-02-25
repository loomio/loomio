Feature: Inbox
  As a user
  So that I can stay up to date with what's happening on Loomio
  I want to quickly see and clear all my unread activity

  Background:
    Given I am logged in

  @javascript
  Scenario: User views discussion in inbox
    Given I belong to a group with a discussion
    When I visit the inbox
    Then I should see the unread discussion

  @javascript
  Scenario: User clears discussion in inbox
    Given I belong to a group with a discussion
    When I visit the inbox
    And I click to view the discussion
    And I visit the inbox again
    Then the inbox should be empty

  Scenario: User views motion in inbox
    Given I belong to a group with a motion
    When I visit the inbox
    Then I should see the motion

  @javascript
  Scenario: User marks discussion as read
    Given I belong to a group with a discussion
    When I visit the inbox
    And I mark the discussion as read
    Then the discussion should disappear

  @javascript
  Scenario: User marks motion as read
    Given I belong to a group with a motion
    When I visit the inbox
    And I mark the motion as read
    Then the motion should disappear

  Scenario: Discussion with no comments gives 1 unread
    Given I belong to a group with a discussion
    When I visit the inbox
    Then I should see the discussion has 1 unread

  Scenario: Discussion with 1 comment gives 2 unread
    Given I belong to a group with a discussion
    And the discussion has a comment
    When I visit the inbox
    Then I should see the discussion has 2 unread

  @javascript
  Scenario: Read discussion with 1 unread comment gives 1 unread
    Given I belong to a group with a discussion
    And I have read the discussion but there is a new comment
    When I visit the inbox
    Then I should see the discussion has 1 unread

  @javascript
  Scenario: User marks all in list as read
    Given I belong to a group with several discussions
    When I visit the inbox
    And I click 'Clear'
    Then the discussions should disappear
