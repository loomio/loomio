Feature: Login
In order to use the site
They must be able to login


Scenario: Login
Given I am a registered User
When enter my login details
Then I am logged in


Scenario: Not A Registered User
Given I am not a registered User
When I enter my incorrect login details
Then I am not logged in


Scenario: Invalid Email
Given I am a registered User
When I enter my email incorrectly
Then I am not logged in

Scenario: Invalid Password
Given I am a registered User
When I enter my password incorrectly
Then I am not logged in