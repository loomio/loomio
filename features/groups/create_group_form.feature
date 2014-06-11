Feature: Create a new group form

  Background:
    Given I am logged in
    And I am on the create a group page

  @javascript
  Scenario: Group is made public
    When a group is made visible, join on request
    Then discussion privacy is set to public, and other options are disabled

  Scenario: Group is made visible, join on approval
    When a group is made visible, join on approval
    And all 3 discussion privacy options are available

  Scenario: Group is made private
    When a group is made hidden
    Then the form selects invitation only, and disables other join options
    And private discussions only is selected, other privacy options disabled
