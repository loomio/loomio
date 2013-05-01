Feature: Setup group
  As a group admin
  So I can set up my group to start using Loomio
  I want to be taken through the setup process

  Background:
    Given I am logged in
    And I am an admin of a group
    And the users time-zone has been set
    And I visit the group setup wizard for that group
    And I fill in the form upto the invites tab

@javascript
  Scenario: Group admin navigates back through the pages
    When I click the "prev" button
    Then I should see the setup decision tab
    When I click the "prev" button
    Then I should see the setup discussion tab
    When I click the "prev" button
    Then I should see the setup group tab

@javascript
  Scenario: Group admin clicks finish at the end of the wizard
    And I fill in the invites panel
    And I click the "send_invites" button
    Then I should see the finished page
    And the group_setup should be created
    And the group should have a discussion
    And the discussion should have a motion
    And invitations should be sent out to each recipient
    When I click the "finished" button
    Then I should see the group page

@javascript
  Scenario: Group admin tries to send valid and invalid emails
    When I fill in a list of valid and invalid emails
    And I click the "send_invites" button
    Then I should see the finished page
    And  I should see a flash message displaying number of valid emails
    And  I should see a list of the valid emails

