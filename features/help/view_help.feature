Feature: View help
  As a Loomio user
  So that I can get some help with the app
  I want to access the help page

  Background:
    Given I am logged in

  Scenario: User visits help page
    When I visit the help page
    Then I should see some help
