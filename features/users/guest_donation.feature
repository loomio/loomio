Feature: Guest Donation
  As a guest
  So that I can support the project
  I would like to pay a monetary contribution to Loomio

  Scenario: Guest makes a contribution
    Given I am not logged in
    When I visit the home page
    And I click the donate tab
    Then I should see the contribution page
