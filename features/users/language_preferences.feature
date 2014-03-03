Feature: Language preferences
  In order to utilise the site
  Users must be able view it in their prefered language

  @javascript
  Scenario: Logged out user with browser language header that does not match available translations
    Given I am not logged in
    And my browser language header is set to "garbage"
    When I visit the sign in page
    Then I should see "Log in"

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
    When I am on the profile page
#    Then I should see "Ajustes de usuario"

  @javascript
  Scenario: Logged in user with language preference
    Given I am logged in
    And my browser language header is set to "es"
    And my language preference is set to "en"
    When I am on the profile page
    Then I should see "profile"

  @javascript
  Scenario: Logged in user changes language preference from User Settings page
    Given I am logged in
    When I am on the profile page
    Then I should see "profile"
    And I change my language preference to Espanol
    When I am on the profile page
#    Then I should see "Ajustes de usuario"

  @javascript
  Scenario: Logged in user changes languge preference from links in footer
    Given I am logged in
    And my browser language header is set to "es"
    And my language preference is set to "hu"
    When I visit "/?locale=ro"
    And I visit "/help"
    Then I should see "Cum functioneaza"

  Scenario: User sets their language preference on sign up page
    Given there is a group
    And an invitation to join the group has been sent to "jim@jam.com"
    When I open the email and click the accept invitation link
    And I sign up as a new user speaking "Español"
    Then I should be a member of the group
    And I should be redirected to the group page
    And I should see "Página principal"
