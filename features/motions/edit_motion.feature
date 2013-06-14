Feature: Admin/author edits a proposal
  As a Loomio group admin or an authour of a proposal
  So that I can change the title, description or close date
  I want to be able to edit the proposal

  Scenario: Admin edits a proposal
    Given I am logged in
    And I am an admin of a group with a discussion
    And the discussion has an open proposal
    When I visit the discussion page
    And I click the edit proposal button
    Then I should see the edit proposal form
    When I change the description
    And I click the update button
    Then I should see see the discussion page
    And I should see the updated description
    And I should see the motion revision link

  Scenario: Author edits a proposal
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And there is a proposal that I have created
    When I visit the discussion page
    And I click the edit proposal button
    Then I should see the edit proposal form

  Scenario: Logged in member tries to edit the proposal
    Given I am logged in
    And I am a member of a group
    And there is a discussion in the group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see a link to edit the proposal

  Scenario: Non member tries to edit the proposal
    Given there is a discussion in a public group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see a link to edit the proposal

  Scenario: User views revision history
    Given there is a discussion in a public group
    And the discussion has an open proposal
    And the proposal has been edited
    When I visit the discussion page
    # And I click the motion revision link
    # Then I should see the revision history page
    # And I should see the original version
    # And I should see the new version

  Scenario: User tries to view revision history when their is not one
    Given there is a discussion in a public group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see the revision link
