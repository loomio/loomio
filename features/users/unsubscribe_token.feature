Feature: Unsubscribe Token allows access to modify email settings

  @javascript
  Scenario: User modifies email preferences via unsubscribe link
    Given I have a user account but not I'm logged in
    And I am subscribed to missed yesterday email
    When I visit email_preferences with unsubscribe_token in the params
    Then I should be able to update my email preferences

  @javascript
  Scenario: User changes volume for all groups
    Given I have a user account but not I'm logged in
    And I am subscribed to missed yesterday email
    When I visit email_preferences with unsubscribe_token in the params
    And change the group volume to quiet
    Then all my groups should be quiet

  @javascript
  Scenario: User changes volume for all groups
    Given I have a user account but not I'm logged in
    And I am subscribed to missed yesterday email
    And I visit email_preferences
    Then I should see the sign-in page
