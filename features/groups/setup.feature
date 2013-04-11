Feature: Setup group
  As a group admin
  So I can set up my group to start using Loomio
  I want to be taken through the setup process

  Background:
    Given I am logged in
    And I am an admin of a group

  Scenario: Group admin is taken to the start of the group setup process
    When I visit the group setup wizard for that group
    Then I should see the group setup wizard

  Scenario: Group admin navigates back and forth through the pages
    When I visit the group setup wizard for that group
    Then I should see the setup group tab
    When I click the next button
    Then I should see the setup discussion tab
    When I click the next button
    Then I should see the setup decission tab

    When I click the prev button
    Then I should see the setup discussion tab
    When I click the prev button
    Then I should see the setup group tab

