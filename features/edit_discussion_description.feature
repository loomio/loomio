Feature: User edits discussion description
  As a Loomio group member
  So that I can help facilitate discussions
  I want to edit the discussion description

  Scenario: Group member edits discussion description
    Given I am logged in
    And there is a discussion in a group I belong to
    When I visit the discussion page
    And I choose to edit the discussion description
    And I fill in and submit the discussion description form
    Then I should see the new discussion description
