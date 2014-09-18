Feature: User deactivates their account

@javascript
Scenario: User deactivates their account
  Given I am logged in
  When I visit the profile page
  And I click the deactivate account button
  Then I should be asked why I am deactivating my account

  When I provide a response and confirm my decision
  Then I should see the sign-in page with confirmation that my account has been deactivated
  And my deactivation_response attribute should be set

Scenario: Only group coordinator tries to deactivate their account
  Given I am the only coordinator of a group
  And I am logged in
  When I visit the profile page
  And I click the deactivate account button
  Then I should be told that I cannot deactivate my account
