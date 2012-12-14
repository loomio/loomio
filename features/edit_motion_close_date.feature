Feature: Admin/author edits a proposal close date
  As a Loomio group admin or an authour of a proposal
  I want to be able to edit the close date of a proposal

  Scenario: Admin extends a proposal close date
    Given I am logged in
    And I am an admin of a group with a discussion
    And the discussion has an open proposal
    When I visit the discussion page
    And I click the 'change close date' button
    And I select the new close date
    Then The proposal close date should be updated
    And I should see a record of my change in the discussion feed

    Scenario: Logged in non-admin/author tries to edit the motion close date
    Given there is a discussion in a group
    And the discussion has an open proposal
    And I am logged in
    When I visit the discussion page
    Then I should not see a link to edit the close date

    Scenario: Non member tries to edit the motion close date
    Given there is a discussion in a group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see a link to edit the close date