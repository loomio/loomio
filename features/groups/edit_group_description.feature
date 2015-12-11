Feature: User edits group description
  As a Loomio user
  I want to be able to edit the group description
  So I can provide a clear context for the group

  @javascript
  Scenario: User tries to edit the group description when they don't belong to the group
    Given I am logged in
    And there is a discussion in a group
    When I visit the group page
    Then I should not see a link to edit the group description
