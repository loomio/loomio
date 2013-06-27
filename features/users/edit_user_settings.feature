Feature: Edit user settings
  As a user
  So that I can customise my profile
  I want to update my display name

  Background:
    Given I am logged in
    And I am a member of a group
    And I visit the user settings page

  @javascript
  Scenario: User updates display name
    And I fill in and submit the new name
    When I visit the group page
    Then I should see my display name has been updated

  @javascript
  Scenario: User changes their email address
    And I fill in and submit "poro@rubyschool.com" as the new email
    When I log out
    And I visit the sign in page
    And I sign in with "poro@rubyschool.com"
    Then I should see the my logged in home page

  @javascript
  Scenario: User updates profile photo
    And I upload a profile image
