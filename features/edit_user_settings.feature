Feature: Edit user settings
  As a user
  So that I can customise my profile
  I want to update my display name and profile image

  Background:
    Given I am logged in
    And I am a member of a group

  Scenario: User updates display name
    And I visit the user settings page
    And I update my display name
    And I click "Update Settings"
    When I visit the group page
    Then I should see my display name has been updated

  Scenario: User updates profile photo
    Given I visit the user settings page
    And I upload a profile image