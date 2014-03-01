Feature: No beta logo for manual subscription users
  As a user
  So I can feel like I'm getting value from a professional tool
  I want to see the non-beta logo in-app

  Background:
    Given I am logged in

  Scenario: Manual Subscription user doesn't see beta logo
    When I am a member a manual subcription group
    Then I should not see the beta logo

  Scenario: All other users see beta logo
    When I am not a member of a manual subcription group
    Then I should see the beta logo
