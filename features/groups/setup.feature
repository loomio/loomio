Feature: Setup group
  As a group admin
  So I can set up my group to start using Loomio
  I want to be taken through the setup process

  Background:
    Given I am logged in

  Scenario: Group admin sets up a group
    Given I am an admin of a group
    And I visit the group setup page
    And I complete the group setup form
    Then the group should be setup
    And I should be on the group page

  Scenario: Group admin tries to set up a group that alredy has been set up
    Given I am an admin of a group
    And the group is already setup
    When I visit the group setup page
    Then I should be redirected to the group page
    And I should be notified it has already been setup

  Scenario: Non group admin tries to set up a group
    Given I am a member of a group
    When I visit the group setup page
    Then I should be told that I dont have permission to set up this group

