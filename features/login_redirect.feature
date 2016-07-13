Feature: Login redirect

@javascript
Scenario: Login with no groups redirects to explore
  Given I have no groups
  When I login
  Then I should arrive on the explore page

Scenario: Login with 1 group redirects to group
  Given I have 1 group
  When I login
  Then I should arrive on my group page

Scenario: Login with many group redirects to dashboard
  Given I have more than 1 group
  When I login
  Then I should arrive on the dashboard page
