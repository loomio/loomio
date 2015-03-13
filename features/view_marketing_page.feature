Feature: View marketing page
  In order to find out more about Loomio
  I want to view the marketing page

  Background:
    Given I want to show the loomio.org marketing

  Scenario: Guest views marketing page
    Given I am a guest
    When I visit the Loomio home page
    Then I should see the marketing page
