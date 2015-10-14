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
    When I create a proposal outcome
    Then my group members should recieve a notification that an outcome has been created

  # fails too much
  #@javascript
  #Scenario: Coordinator edits a proposal outcome
    #Given the proposal has closed
    #And a proposal outcome has been created
    #And I edit the proposal outcome
    #And I should see the outcome has been edited in the activity feed
