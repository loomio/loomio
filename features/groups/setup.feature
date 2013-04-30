Feature: Setup group
  As a group admin
  So I can set up my group to start using Loomio
  I want to be taken through the setup process

  Background:
    Given I am logged in
    And I am an admin of a group
    And the users time-zone has been set

@javascript
  Scenario: Group admin is taken to the start of the group setup process
    When I visit the group setup wizard for that group
    Then I should see the group setup wizard

@javascript
  Scenario: Group admin navigates back and forth through the pages
    When I visit the group setup wizard for that group
    Then I should see the setup group tab
    And I fill in the group panel
    When I click the "next" button
    Then I should see the setup discussion tab
    And I fill in the discussion panel
    When I click the "next" button
    Then I should see the setup decision tab
    And I should see my time zone set in the timezone select
    And I fill in the motion panel
    When I click the "next" button
    Then I should see the setup invites tab

    When I click the "prev" button
    Then I should see the setup decision tab
    When I click the "prev" button
    Then I should see the setup discussion tab
    When I click the "prev" button
    Then I should see the setup group tab

@javascript
  Scenario: Group admin clicks finish at the end of the wizard
    When I visit the group setup wizard for that group
    And I fill in the group panel
    And I click the "next" button
    And I fill in the discussion panel
    And I click the "next" button
    And I fill in the motion panel
    And I click the "next" button
    And I fill in the invites panel
    And I click the "send_invites" button
    Then I should see the finished page
    And the group_setup should be created
    And the group should have a discussion
    And the discussion should have a motion
    And invitations should be sent out to each recipient
    When I click the "finished" button
    Then I should see the group page
