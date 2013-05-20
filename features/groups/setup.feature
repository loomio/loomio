Feature: Setup group
  As a group admin
  So I can set up my group to start using Loomio
  I want to be taken through the setup process

  Background:
    Given I am logged in

@javascript
  Scenario: Group admin navigates back through the pages
    Given I am an admin of a group
    And the users time-zone has been set
    And I visit the group setup wizard for that group
    And I fill in the form upto the invites tab
    When I click the "prev" button
    Then I should see the setup discussion tab
    When I click the "prev" button
    Then I should see the setup group tab

@javascript
  Scenario: Group admin tries to send valid and invalid emails
    Given I am an admin of a group
    And the users time-zone has been set
    And I visit the group setup wizard for that group
    And I fill in the form upto the invites tab
    When I fill in a list of valid and invalid emails
    And I click the "send_invites" button
    And  I should see a flash message displaying number of valid emails
    And  I should see the group page

@javascript
  Scenario: Group admin sets up a group
    Given I am an admin of a group
    And the users time-zone has been set
    And I visit the group setup wizard for that group
    And I fill in the form upto the invites tab
    And I fill in the invites panel
    And I click the "send_invites" button
    And the group_setup should be created
    And the group should have a discussion
    And invitations should be sent out to each recipient
    Then I should see the group page
    And the date the group was setup is stored

@javascript
  Scenario: Group admin tries to set up a group that alredy has been set up
    Given I am an admin of a group
    And the users time-zone has been set
    And a group is already setup
    When I visit the group setup wizard for that group
    Then I should be told that the group has already been setup

@javascript
  Scenario: Non group admin tries to set up a group
    Given I am a member of a group
    When I visit the group setup wizard for that group
    Then I should be told that I dont have permission to set up this group

