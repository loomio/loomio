Feature: Setup group
  As a group admin
  So I can set up my group to start using Loomio
  I want to be taken through the setup process

  Background:
    Given I am logged in

  Scenario: Group admin sets up a group
    Given I am an admin of a parent group that has not completed setup
    When I visit the group setup page
    And I complete the group setup form
    Then the group should be setup
    And I should be on the group page

  Scenario: Group admin tries to set up a group that alredy has been setup
    Given I am an admin of a group
    When I visit the group setup page
    Then I should be redirected to the group page
    And I should be notified it has already been setup

  Scenario: Non group admin tries to setup a group
    Given I am a member of a group that has not completed setup
    When I visit the group setup page
    Then I should be told that I dont have permission to set up this group

  Scenario: Ensure group has been setup
    Given I am an admin of a parent group that has not completed setup
    When I visit the group page
    Then I should be redirected to the group setup

  Scenario: Do not ensure setup for subgroups
    Given I am an admin of a subgroup group that has not completed setup
    When I visit the subgroup page
    Then I should see the subgroup page
