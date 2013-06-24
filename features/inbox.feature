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

  Scenario: Voted motions don't show in inbox
    Given I belong to a group with a motion
    And I have voted on the motion
    When I visit the inbox
    Then the inbox should be empty

  Scenario: User marks discussion as read
    Given I belong to a group with a discussion
    When I visit the inbox
    And I mark the discussion as read
    Then the discussion should disappear

  @javascript
  Scenario: User marks all discussions in group as read
    Given I belong to a group with several discussions
    When I visit the inbox
    And I click 'Mark all as read'
    Then the discussions should disappear

    

  #Scenario: User unfollows discussion
    #Given I belong to a group with a discussion
    #When I visit the inbox
    #And I mark the discussion as hidden
    #And there is more activity on the discussion
    #Then the discussion should not show in inbox
   


  Scenario: Signed out user tries to view inbox

