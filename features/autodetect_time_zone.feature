Feature: Autodetect the time zone of the user on login or signup
  In order to know the user timezone
  So that we can display times in the local format
  We need to autodetect the user timezone

  @javascript
  Scenario: User with no time_zone defined signs in
    Given I have a user account with no time_zone
    When I sign in
    Then I should have a time_zone defined

  @javascript
  Scenario: Invited user signs up and has time_zone defined
    Given I am invited to join a Loomio Group
    And I follow the invitation link
    When I sign up as a new user
    Then the new user should have a time zone
