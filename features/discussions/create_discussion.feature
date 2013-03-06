Feature: User creates discussion
  As a member of a group
  So that I can bring up topics to discuss with the group
  I want to be able to start new discussions

  Background:
    Given I am logged in
    And I am a member of a group

  Scenario: Group member creates discussion from group page
    When I visit the group page
    And I choose to create a discussion
    And I fill in the discussion details and submit the form
    Then a discussion should be created

  Scenario: Group member creates discussion from dashboard
    When I visit the dashboard
    And I choose to create a discussion
    And I select the group from the groups dropdown
    And I fill in the discussion details and submit the form
    Then a discussion should be created

  Scenario: Members get emailed when a discussion is created
    Given "Ben" is a member of the group
    And "Hannah" is a member of the group
    And no emails have been sent
    And "Ben" has chosen to be emailed about new discussions and decisions for the group
    And "Hannah" has chosen not to be emailed about new discussions and decisions for the group
    When I visit the group page
    And I choose to create a discussion
    And I fill in the discussion details and submit the form
    Then "Ben" should be emailed about the new discussion
    And clicking the link in the email should take him to the discussion
    And "Hannah" should not be emailed about the new discussion
