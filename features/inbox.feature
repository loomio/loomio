Feature: Inbox
  As a user
  So that I can stay up to date with what's happening on Loomio
  I want to quickly see and clear all my unread activity

  Background:
    Given I am logged in

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

  # voted motions will show in inbox.. if there is new activity.
  #Scenario: Voted motions don't show in inbox
    #Given I belong to a group with a motion
    #And I have voted on the motion
    #When I visit the inbox
    #Then the inbox should be empty

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

  @javascript
  Scenario: User marks all in group as read
    Given I belong to a group with more than max per inbox group discussions
    When I visit the inbox
    And I click 'clear them all'
    Then all the discussions in the group should be marked as read

  #Scenario: User unfollows discussion
    #Given I belong to a group with a discussion
    #When I visit the inbox
    #And I mark the discussion as hidden
    #And there is more activity on the discussion
    #Then the discussion should not show in inbox

  #Scenario: User joins new group and only sees recent activity
    #When I join a group
    #And I visit the inbox
    #Then I should only see that groups recent discussions and current motions
