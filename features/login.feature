Feature: Login
  In order to use the site
  Users must be able to login

  Scenario: Login
    Given "hello@world.com" is a user
    When I login as "hello@world.com"
    Then I should be logged in

  Scenario: Login to an empty group
    Given a group "demo-group" with "hello@world.com" as admin
    When I login as "hello@world.com"
    Then I should be logged in

  Scenario: Not A Registered User
    When I login as "hello@world.com"
    Then I should not be logged in

  Scenario: Invalid Password
    Given "hello@world.com" is a user
    When I login as "hello@world.com" with an incorrect password
    Then I should not be logged in
