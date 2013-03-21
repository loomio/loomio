Feature: User edits group description
  As a Loomio user
  I want to be able to edit the group description
  So I can provide a clear context for the group

  Scenario: User edits the group description
    Given I am logged in
    And there is a discussion in a group I belong to
    And I visit the group page
    When I choose to edit the group description
    And I fill in and submit the group description form
    Then I should see the group description change

  Scenario: User tries to edit the group description when they don't belong to the group
    Given there is a discussion in a group
    And I am not a member of the group
    When I visit the group page
    Then I should not see a link to edit the group description