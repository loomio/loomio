Feature: User requests to join group
  As a Loomio user
  So that I can participate in discussions I'm interested in
  I want to be able to join groups

  Scenario: User requests to join group
    Given I am logged in
    And a public group exists
    When I visit the group page
    And I click "Request membership"
    Then I should see "Membership requested"
    And the group admins should receive an email with subject "You've been added to a group"

  Scenario: Group Admin accepts membership request
    Given I am logged in
    And a public group exists
    When I visit the group page
    And I click "Request membership"
    Then the request is approved
    And I should get an email with subject "Membership approved"

  Scenario: Parent group member requests to join subgroup
    Given I am logged in
    And I am a member of a parent-group that has a sub-group viewable by parent-group members
    When I visit the sub-group page
    And I click "Request membership"
    Then I should see "Membership requested"

  Scenario: Parent non-member tries to request to join subgroup
    Given I am logged in
    And a public sub-group exists
    When I visit the sub-group page
    Then I should not see "Request membership"
