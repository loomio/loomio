Feature: Coordinator subscribes to plan

  Background:
    Given I am logged in
    And I am a coordinator of a subscription group
    And I have not selected a subscription plan

  Scenario: Coordinator subscribes to plan
    When I visit the new subscription page for the group
    And I choose and pay for the plan "$25 per month"
    Then I should see a page telling me I have subscribed
    And the group's subscription details should be saved

  Scenario: Coordinator subscribes to custom plan
    When I visit the new subscription page for the group
    And I choose and pay for a custom plan
    Then I should see a page telling me I have subscribed
    And the group's subscription details should be saved

  Scenario: Coordinator chooses invalid custom plan
    When I visit the new subscription page for the group
    And I try to pay an invalid custom amount
    Then I should be told the amount was invalid

  @javascript
  Scenario: Coordinator subscribes to $0 plan
    When I visit the new subscription page for the group
    And I choose the $0 per month plan
    Then I should see the love note pop up
    And I should see the button text change

    When I click "Submit"
    Then I should see a page telling me I have subscribed
    And the group's subscription details should be saved

  Scenario: Paypal confirmation failure
    When I visit the paypal confirmation page and give bad data
    Then the group's subscription details should not be saved
    And I should see a page telling me the payment failed
