Feature: View user profile
  As a user
  So I can view other user's profile information
  I want to view other user's profile page

  Scenario: User views other user's profile page
    Given I am logged in
    And I am in one of the same groups as another user
    When I visit the other user's profile page
    Then I should see the other user's public groups

  Scenario: User tries to view other user's profile page when not in the same group
    Given I am logged in
    And I am not in any of the same groups as another user
    When I visit the other user's profile page
    Then I should not see the other user's profile information
    And I should not see any group the other user is in

  Scenario: Signed out user tries to view other user's profile page
    Given I am not logged in
    And another user exists
    When I visit the other user's profile page
    Then I should not see the other user's profile information
    And I should not see any group the other user is in
