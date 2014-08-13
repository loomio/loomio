Feature: User creates discussion
  As a member of a group
  So that I can bring up topics to discuss with the group
  I want to be able to start new discussions

  Background:
    Given I am logged in
    And I am a member of a group
    And my global markdown preference is 'disabled'

  @javascript
  Scenario: Group member creates discussion from group page
    When I visit the group page
    And I choose to create a discussion
    And I fill in the discussion details and submit the form
    Then a discussion should be created

  @javascript
  Scenario: Group member creates discussion from dashboard
    When I visit the dashboard
    And I choose to create a discussion
    And I select the group from the groups dropdown
    And I fill in the discussion details and submit the form
    Then a discussion should be created
