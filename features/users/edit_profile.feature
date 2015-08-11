Feature: User edits profile
  As a user
  So that I can customise my profile
  I want to update my user information

  Background:
    Given I am logged in
    And I am a member of a group
    And I visit the profile page

  #@javascript
  #Scenario: User updates display name
    #When I fill in and submit the new name
    #And I visit the group page
    #Then I should see my display name has been updated

  @javascript
  Scenario: User updates email
    When I change my email to "poro@rubyschool.com" and submit the form
    And I log out
    And I visit the sign in page
    And I log in with "poro@rubyschool.com"
    Then I should see the logged in homepage

  @javascript
  Scenario: User updates username
    When I update my username
    And I view my user profile
    Then I should see my username has been updated

  @javascript
  Scenario: User is prevented from changing username to contain whitespace
    When I edit my username to contain whitespace
    And And I submit the form
    Then I should see an error message on the form
    And my username should not be updated

  @javascript
  Scenario: User updates profile photo
    Given I visit the profile page
    And I upload a profile image
