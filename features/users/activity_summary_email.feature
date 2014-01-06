Feature: Activity summary email
  In order to stay up to date with activity via email
  I want to receive an accurate summary of each of new activity since the last summary

  Background:
    Given I am logged in
    And I am a member of a group with a discussion

  Scenario: Groups with new unread activity are displayed
    And the discussion has a new comment I have not read
    When I am sent an activity summary email
    Then I should see the group name in the email

  Scenario: Discussions with new unread comment activity are displayed
    And the discussion has a new comment I have not read
    When I am sent an activity summary email
    Then I should see the discussion title in the email

  Scenario: Discussions with new unread motions are displayed
    And the discussion has a new motion I have not read
    When I am sent an activity summary email
    Then I should see the discussion title in the email

  Scenario: Discussions with new unread position activity are displayed
    And the discussion has a motion
    And the motion has a new position statement by another user I have not read
    When I am sent an activity summary email
    Then I should see the discussion title in the email

  Scenario: Unread motions are displayed
    And the discussion has a new motion I have not read
    When I am sent an activity summary email
    Then I should see the motion name in the email

  Scenario: Motions with new unread position activity are displayed
    And the discussion has a motion
    And the motion has a new position statement by another user I have not read
    When I am sent an activity summary email
    Then I should see the motion name in the email

  Scenario: Read comments are not displayed
    And the discussion has a comment I have read
    When I am sent an activity summary email
    Then I should not see the comment in the email

  Scenario: Read positions are not displayed
    And the discussion has a motion
    And the motion has a position statement by another user I have read
    When I am sent an activity summary email
    Then I should not see the position in the email

  Scenario: New unread discussions are displayed and do not have thier description truncated
    And there is a new discussion in the group with a long description
    When I am sent an activity summary email
    Then I should not see the description truncated in the email

  Scenario: Previously read discussions with new activity have their description truncated
    And there is a new discussion in the group with a long description
    And the discussion has been read
    And the discussion has a new comment I have not read
    When I am sent an activity summary email
    Then I should see the description truncated in the email

  Scenario: New unread motions are displayed and do not have thier description truncated
    And the discussion has a new motion I have not read
    And the motion has a new position statement by another user I have not read
    When I am sent an activity summary email
    Then I should not see the description truncated in the email

  Scenario: Previously read motions with new activity have their description truncated
    And the discussion has a motion
    And the motion has a new position statement by another user I have not read
    When I am sent an activity summary email
    Then I should see the description truncated in the email

  Scenario: Groups with no unread activity are not displayed
    And the discussion has been read
    When I am sent an activity summary email
    Then I should not see the group name in the email

  Scenario: Discussions with no unread activity are not displayed
    And the discussion has been read
    When I am sent an activity summary email
    Then I should not see the discussion title in the email

  Scenario: Motions with no unread activity are not displayed
    And the discussion has a motion
    When I am sent an activity summary email
    Then I should not see the motion name in the email

  Scenario: Groups with old unread activity are not displayed

  Scenario: Discussions with old unread activity are not displayed

  Scenario: Motions with old unread activity are not displayed