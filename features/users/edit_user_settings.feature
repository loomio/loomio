Feature: Edit user settings
  As a user
  So that I can customise my profile
  I want to update my display name

  Background:
    Given I am logged in
    And I am a member of a group

  Scenario: User updates display name
    And I visit the user settings page
    And I fill in and submit the new name
    When I visit the group page
    Then I should see my display name has been updated

  Scenario: User updates profile photoc
    Given I visit the user settings page
    And I upload a profile image

  Scenario: User selects time_zone
    Given I visit the user settings page
    When I select my time_zone and click update
    Then my time_zone is stored in the database