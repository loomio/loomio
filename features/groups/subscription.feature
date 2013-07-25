Feature: Coordinator chooses subscription
  As a group Coordinator
  So I can set up a subscription for my group
  I want to select a plan

  Background:
    Given I am logged in

  Scenario: Coordinator chooses a plan
    Given I am a coordinator of a subscription group
    And I have not selected a subscription plan
    When I visit the group page
    And I select Payment details
    Then I should see links to the different plans

  Scenario: Coordinator sees their payment details
    Given I am a coordinator of a subscription group
    And I have already selected a subscription plan
    When I visit the group page
    And I select Payment details
    Then I should see the payment details for my group
    And I should be told that I can email to change my plan

  Scenario: Member cannot see payment details
    Given I am a member of a subscription group
    When I visit the group page
    Then I should not see a link to payment details

    When I visit the payment details page
    Then I should be redirected to the dashboard

  Scenario: Coordinator for PWYC group cannot see payment details
    Given I am a coordinator of a PWYC group
    When I visit the group page
    Then I should not see a link to payment details

    When I visit the payment details page
    Then I should be redirected to the group page
