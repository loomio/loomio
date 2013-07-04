Feature: Language preferences
  In order to utilise the site
  Users must be able view it in their prefered language

  @javascript
  Scenario: Logged out user with browser language header that does not match available translations
    Given I am not logged in
    And my browser language header is set to "garbage"
    When I visit the sign in page
    Then I should see "Sign in"

  @javascript
  Scenario: Logged out user with browser language header that matches available translation
    Given I am not logged in
    And my browser language header is set to "es"
    When I visit the sign in page
    Then I should see "Entrar"

  @javascript
  Scenario: Logged in user without language preference
    Given my browser language header is set to "es"
    And I am logged in
    And I have not set my language preference
    When I am on the settings page
    Then I should see "Preferencias de Usuario"

  @javascript
  Scenario: Logged in user with language preference
    Given I am logged in
    And my browser language header is set to "es"
    And my language preference is set to "en"
    When I am on the settings page
    Then I should see "User Settings"

  @javascript
  Scenario: Logged in user changes language preference from User Settings page
    Given I am logged in
    When I am on the settings page
    Then I should see "User Settings"
    And I change my language preference to Espanol
    When I am on the settings page
    Then I should see "Preferencias de Usuario"

  @javascript
  Scenario: Logged in user changes languge preference from URL params
    Given I am logged in
    And my browser language header is set to "es"
    And my language preference is set to "hu"
    When I visit "/?locale=ro"
    And I visit "/help"
    Then I should see "Cum functioneaza"
