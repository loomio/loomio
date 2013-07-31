Feature: Coordinator subscribes to plan

  Background:
    Given I am logged in
    And I am a coordinator of a subscription group
    And I have not selected a subscription plan

  Scenario: Coordinator subscribes to plan
    When I visit the new subscription page for the group
    And I choose and pay for the plan "$30/month"
    Then I should see a page telling me I have subscribed
    And the group's subscription details should be saved

  Scenario: Paypal confirmation failure
    When I visit the paypal confirmation page and give bad data
    Then the group's subscription details should not be saved
    And I should see a page telling me the payment failed

  Scenario: All of the plans work
    When I visit the new subscription page for the group
    Then I should see buttons for all the different plans
