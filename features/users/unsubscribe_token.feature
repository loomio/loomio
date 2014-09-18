Feature: Unsubscribe Token allows access to modify email settings

  @javascript
  Scenario: User modifies email preferences via unsubscribe link
    Given I have a user account but not I'm logged in
    And I am subscribed to missed yesterday email
    When I visit email_preferences with unsubscribe_token in the params
    Then I should be able to update my email preferences

