Feature: App logo is set appropriately in banner 

  Background:
    Given I am logged in

  Scenario: Manual Subscription user doesn't see beta logo on loomio.org
    And I am a member a manual subcription group
    Then I should not see the beta logo

  Scenario: non-subscription users see beta logo on loomio.org
    And I am not a member of a manual subcription group
    Then I should see the beta logo

  Scenario: private installation of loomio see there own logo
    And I am not a member of a manual subcription group
    And my system admin defined us a custom logo
    Then I should see our custom logo instead of any loomio logo

