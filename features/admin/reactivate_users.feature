Feature: Reactivate Users

  As a Loomio admin
  So that I can meet the requests of users who ask to have their accounts reactivated
  I want to be able to reactivate deactivated user accounts from the admin panel

  Scenario: User's account is reactivated
    Given there is a user with a deactivated account
    When their account is reactivated
    Then the user's deactivated_at attribute should be set to nil
    And the user's memberships should be restored
    When they attempt to sign in
    Then they should see the dashboard
    And they should be able to view their groups
    