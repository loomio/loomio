Feature: SiteTheme
  As a group coordinator
  So I can customise the look of the application when using my group
  I want to be able to theme the application css and images

  Background:
    Given I am logged in

  Scenario: User sees themed group
    Given there is a group with a theme associated
    When I visit the group page
    Then I should see the theme
    When I visit the a discussion in that themed group
    Then I should see the theme

  Scenario: User visits themed group subdomain login page
    When I visit a login page on a subdomain of a group with a theme
    Then I should see the theme
