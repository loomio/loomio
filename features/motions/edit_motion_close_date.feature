Feature: Admin/author edits a proposal close date
  As a Loomio group admin or an authour of a proposal
  I want to be able to edit the close date of a proposal

  @javascript
  Scenario: Admin extends a proposal close date
    Given I am logged in
    And I am an admin of a group with a discussion
    And the discussion has an open proposal
    When I visit the discussion page
    And I click the 'change close date' button
    Then I should see the edit close date modal

    When I select the new close date
    Then The proposal close date should change
    And I should see a record of my change in the discussion feed

  Scenario: Logged in non-admin/author tries to edit the motion close date
    Given there is a discussion in a public group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see a link to edit the close date

  Scenario: Non member tries to edit the motion close date
    Given there is a discussion in a public group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see a link to edit the close date
