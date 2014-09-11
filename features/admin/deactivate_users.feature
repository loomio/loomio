Feature: Deactivate Users

  As a Loomio admin
  So that I can meet the requests of users who ask to have their accounts deactivated
  I want to be able to deactivate user accounts from the admin panel

  Scenario: User's account is deactivated
    Given there is a user in a group
    When their account is deactivated
    Then the user's deactivated_at attribute should be set
    And the user's memberships should be archived
    When they attempt to sign in
    Then they should be told their account is inactive
