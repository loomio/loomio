Feature: Coordinator creates proposal outcome
  As a proposal author
  I want to share the outcome of the proposal with other group members
  So that the group is informed of the outcome of a proposal and members can act on the decisions

  Background:
    Given I am logged in
    And I am an admin of a group
    And there is a discussion in the group
    And the discussion has a proposal

  @javascript
  Scenario: Coordinator creates a proposal outcome
    Given the proposal has closed
    And I have recieved an email with subject "Proposal closed"
    When I click the link to create a proposal outcome
    # And I see the proposal outcome field highlighted
    And I specify a proposal outcome
    And I click "Publish outcome"
    Then my group members should receive an email with subject "Proposal outcome"
    And they should recieve a notification that an outcome has been created

  @javascript
  Scenario: Coordinator edits a proposal outcome
    Given the proposal has closed
    And a proposal outcome has been created
    And I edit the proposal outcome
    Then my group members should not receive an email with subject "Proposal outcome"
    And I should see the outcome has been edited in the activity feed

  Scenario: Paying group member receives outcome email without campaign
    Given my group is paying a subscription
    And a proposal outcome has been sent
    Then I should not see the campaign in the email body

  # Scenario: Non-paying group member receives outcome email with campaign
  #   Given my group is not paying a subscription
  #   And a proposal outcome has been sent
  #   Then I should see the campaign in the email body


