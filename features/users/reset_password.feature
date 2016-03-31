Feature: Reset password

  @javascript
  Scenario: User resets their password from log in page
    Given I have a loomio account
    When I reset my password
    Then my password should be reset and I should be logged in
  
