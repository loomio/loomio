Feature: Login
  In order to use the site
  Users must be able to login

  Scenario: Login
    Given "hello@world.com" is a user
    When I login as "hello@world.com"
    Then I should be logged in

  Scenario: Not A Registered User
    When I login as "hello@world.com"
    Then I should not be logged in

  Scenario: Invalid Password
    Given "hello@world.com" is a user
    When I login as "hello@world.com" with an incorrect password
    Then I should not be logged in

  Scenario: Redirected to original page on login
    Given I am a logged out user
    And I am a member of a hidden group
    When I visit the group page
    And I log in
    Then I should see the group page

  @javascript
  Scenario: Redirected to previous public page on login
    Given I am a logged out user
    And there is a public discussion in a public group
    And I visit the discussion page
    And I click on the login button
    And I log in
    Then I should see the discussion