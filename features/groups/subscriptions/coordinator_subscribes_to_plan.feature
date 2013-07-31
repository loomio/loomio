Feature: Coordinator subscribes to plan

  Scenario Outline: Coordinator subscribes to plan
    Given I am logged in
    And I am a coordinator of a subscription group
    And I have not selected a subscription plan
    When I visit the new subscription page for the group
    And I choose and pay for the plan "<plan>" <success>
    Then I should see a page telling me I have <success> subscribed
    And the system should store my subscription

  @javascript
  Scenarios: Coordinator successfully subscribes to plan
    | plan       | success      |
    | $30/month  | successfully |
    | $50/month  | successfully |
    | $100/month | successfully |
    | $200/month | successfully |

  @javascript
  Scenarios: Coordinator unsuccessfully subscribes to plan
    | plan       | success        |
    | $30/month  | unsuccessfully |
    | $50/month  | unsuccessfully |
    | $100/month | unsuccessfully |
    | $200/month | unsuccessfully |

