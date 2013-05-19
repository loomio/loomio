Feature: Error Rainchecks
  As a Loomio admin
  So that I resolve errors when they occur
  I want to be able to see the controller and action being requested when an error occurs

  Scenario: User requests unavailable page
    Given I am logged in
    When I visit the not_found_path and see the error_rainchecks error page
    When I submit a valid email address
    Then I should see the thank you page
    And I should be able to click the 'return to home page' link
    Then I should see the dashboard

  Scenario: Admin sees error_rainchecks in admin panel
    Given I am a Loomio admin
    And I am logged in
    When an error is raised in the show action of the dashboard_controller
    And I enter my email address in the error_rainchecks error page
    Then I should see the thank you page
    When I visit the Error Rainchecks index in the admin panel
    Then I should see the Error Rainchecks
