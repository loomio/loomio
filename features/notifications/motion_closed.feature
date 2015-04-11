Feature: User sees notification that a motion has closed

  Background:
    Given I am logged in

  @javascript
  Scenario: Motion expired
    Given I have a proposal which has expired
    When I visit the dashboard
    And I click the notifications dropdown
    Then I should see that the motion expired
