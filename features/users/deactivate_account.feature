Feature: User deactivates their account

@javascript
Scenario: User deactivates their account
  Given I am logged in
  When I visit the profile page
  And I click the deactivate account button
  Then I should see the sign-in page
  And I should see confirmation that my account has been deactivated

Scenario: Only group coordinator tries to deactivate their account
  Given I am the only coordinator of a group
  And I am logged in
  When I visit the profile page
  And I click the deactivate account button
  Then I should be told that I cannot deactivate my account
