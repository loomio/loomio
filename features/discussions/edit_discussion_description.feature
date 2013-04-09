Feature: User edits discussion description
  As a Loomio user
  I want to be able to edit the discussion description
  So I can provide a clear context for the discussion

  Scenario: User edits the discussion description and changes the discussion markdown preference
    Given I am logged in
    And my global markdown preference is 'disabled'
    And there is a discussion in a group I belong to
    And I am on the discussion page
    When I choose to edit the discussion description
    And I see discussion markdown is disabled
    And I enable markdown for the discussion description
    And I see discussion markdown is enabled
    And I fill in and submit the discussion description form
    Then the discussion desription should render markdown
    And my global markdown preference should still be 'disabled'

  Scenario: User edits the discussion description
    Given I am logged in
    And there is a discussion in a group I belong to
    And I am on the discussion page
    When I choose to edit the discussion description
    And I fill in and submit the discussion description form
    Then I should see the description change
    And I should see a record of my change in the discussion feed

  Scenario: User tries to edit the discussion description when they don't belong to the group
    Given there is a discussion in a group
    And I am not a member of the group
    When I visit the discussion page
    Then I should not see a link to edit the description