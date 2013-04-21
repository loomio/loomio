Feature: User creates discussion
  As a member of a group
  So that I can bring up topics to discuss with the group
  I want to be able to start new discussions

  Background:
    Given I am logged in
    And I am a member of a group
    And my global markdown preference is 'disabled'

  Scenario: Group member creates discussion from group page
    When I visit the group page
    And I choose to create a discussion
    And I see discussion markdown is disabled
    And I enable markdown for the discussion description
    And I fill in the discussion details and submit the form
    Then a discussion should be created
    And the discussion desription should render markdown
    And my global markdown preference should now be 'enabled'

  Scenario: Group member creates discussion from dashboard
    When I visit the dashboard
    And I choose to create a discussion
    And I select the group from the groups dropdown
    And I fill in the discussion details and submit the form
    Then a discussion should be created

  Scenario: Members get emailed when a discussion is created
    Given "Ben" is a member of the group
    And "Hannah" is a member of the group
    And "newuser@example.org" has been invited to the group but has not accepted
    And no emails have been sent
    And "Ben" has chosen to be emailed about new discussions and decisions for the group
    And "Hannah" has chosen not to be emailed about new discussions and decisions for the group
    When I visit the group page
    And I choose to create a discussion
    And I fill in the discussion details and submit the form
    And "ben@example.org" should receive an email
    When "ben@example.org" opens the email
    And clicking the link in the email should take him to the discussion
    And "hannah@example.org" should receive no email
    And "newuser@example.org" should receive no email
