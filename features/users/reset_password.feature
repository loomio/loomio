Feature: Reset password

  @javascript
  Scenario: User resets their password from log in page
    Given I have a loomio account
    When I reset my password
    Then my password should be reset and I should be logged in
  
  @javascript
  Scenario: User resets their password from profile page
    Given I am logged in
    And I visit the profile page
    When I click the change password link
    And I change my password and submit the form
    Then I should be notified that my password has been changed
  
    When I log out
    And I visit the sign in page
    And I log in using my new password
    Then I should see the dashboard
