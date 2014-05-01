Feature: Coordinator sets group privacy to public
  As a group coordinator
  I want to make the group public
  So that anyone can see it

  Background:
    Given I am logged in

  Scenario: Coordinator sets group privacy to public
    Given I am a coordinator of a hidden group
    When I visit the group settings page
    And I set the group to public
    Then the group should be set to public

  Scenario: Visitor views public group
    Given a public group exists
    When I visit the group page
    Then I should see the group title

  Scenario: Group member views public group
    Given I am a member of a public group
    When I visit the group page
    Then I should see the group title

  Scenario: Public group is shared via social media
    Given a public group exists
    When I visit the group page
    Then I should see the group title in the metadata

  Scenario: Visitor views a public sub-group
    Given a public sub-group exists
    When I visit the sub-group page
    Then I should see the subgroup title

  @javascript
  Scenario: Sub-group member views public sub-group
    Given I am a member of a public sub-group
    When I visit the sub-group page
    Then I should see the subgroup title
