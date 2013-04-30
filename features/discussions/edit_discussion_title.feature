Feature: User edits discussion title
  As a Loomio user
  I want to be able to edit the discussion title
  So I can provide a clear context for the discussion

  Scenario: User edits the discussion title
    Given I am logged in
    And there is a discussion in a group I belong to
    And I am on the discussion page
    When I choose to edit the discussion title
    And I fill in and submit the discussion title form
    Then I should see the title change
    And I should see a record of my title change in the discussion feed

  Scenario: User tries to edit the discussion description when they don't belong to the group
    Given there is a discussion in a public group
    When I visit the discussion page
    Then I should not see a link to edit the title
