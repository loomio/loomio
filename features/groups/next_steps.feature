Feature: Next setup steps for group
  As a group admin
  So I can finish setting up my group using Loomio
  I want to be prompted to finish the setup process

  Background:
    Given I am logged in

@javascript
  Scenario: Group admin arrives on a newly setup group page
    Given I am an admin of a group
    And I visit the group page
    Then I should see the next_steps panel

@javascript
  Scenario: Group admin dismisses the next_steps panel
    Given I am an admin of a group
    And I visit the group page
    And I dismiss the next_steps panel
    Then I should not see the next_steps panel
    When I visit the group page
    Then I should not see the next_steps panel

@javascript
  Scenario: User arrives on a newly setup group page
    Given I am a member of a group
    And I visit the group page
    Then I should not see the next_steps panel