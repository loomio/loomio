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
    And I change the description
    And I fill in the edit message
    And I click the update button
    Then I should see the updated description
    And I should see the motion revision link
    And I should see a record of the change in the activity list

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

  Scenario: Members who have voted get emailed when a proposal is edited
    Given I am logged in
    And I am an admin of a group with a discussion
    And the discussion has an open proposal
    And "Ben" is a member of the group
    And "Ben" has voted on the proposal
    And "Hannah" is a member of the group
    And no emails have been sent
    When I visit the discussion page
    And I click the edit proposal button
    And I change the description
    And I fill in the edit message
    And I click the update button
    And "ben@example.org" should receive an email
    When "ben@example.org" opens the email
    And clicking the link in the email should take him to the motion
    And "hannah@example.org" should receive no email

  Scenario: User views revision history
    Given there is a discussion in a public group
    And the discussion has an open proposal
    And the proposal has been edited
    When I visit the discussion page
    And I click the motion revision link
    Then I should see the revision history page
    And I should see the original version
    And I should see the new version

  Scenario: User tries to view revision history when their is not one
    Given there is a discussion in a public group
    And the discussion has an open proposal
    When I visit the discussion page
    Then I should not see the revision link

  Scenario: User does not see votes included in the revision history
    Given there is a discussion in a public group
    And the discussion has an open proposal
    And a vote is made on the proposal
    When I visit the discussion page
    Then I should not see the revision link
