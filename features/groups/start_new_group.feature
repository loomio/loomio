Feature: Start new group
  In order to bring my group onto Loomio
  As a group coordinator
  I want to create a new group

Background:
  Given I want to show the loomio.org marketing
  And There are default group covers available

Scenario: Guest submits invalid start group form
  Given I click 'Try Loomio' from the front page
  When I go to start a new group
  And I click start group without filling in any fields
  Then I should see the start group form with errors

@javascript
Scenario: Guest creates group
  Given I click 'Try Loomio' from the front page
  And I fill in the start group form
  Then I should see the thank you page
  And I should recieve an email with an invitation link
  When I click the invitation link
  And I sign up as a new user
  And I setup the group
  Then I should be taken to the new group
  And the example content should be present
  And I should be the creator of the group
  And the group should be non referral
  And the group should be on a trial subscription

@javascript
Scenario: User creates group
  Given I am logged in
  When I go to start a new group from the navbar
  And I fill in my group name and choose subscription and submit
  And I setup the group
  Then I should be taken to the new group
  And the example content should be present
  And I should be the creator of the group
  And the group should be on a trial subscription
