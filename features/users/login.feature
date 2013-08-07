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
    And I am a member of a private group
    When I visit the group page
    And I log in
    Then I should see the group page
