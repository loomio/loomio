Feature: Start new group
  In order to bring my group onto Loomio
  As a group coordinator
  I want to create a new group

Scenario: Guest submits invalid start group form
  Given I am a guest
  And I am on the home page of the website
  When I go to start a new group
  And I click start group without filling in any fields
  Then I should see the start group form with errors

@javascript
Scenario: Guest creates group
  Given I am a guest
  And I am on the home page of the website
  When I go to start a new group
  And I fill in and submit the form
  Then I should see the thank you page
  And I should recieve an email with an invitation link
  When I click the invitation link
  And I choose to create an account now
  And I sign up as a new user
  And I setup the group
  Then I should see the group page

Scenario: User creates group
  Given I am logged in
  When I go to start a new group from the navbar
  And I complete and submit the form
  Then I should be taken to the new group

@javascript
 Scenario: Logged out user creates group
  Given I am a logged out user
  And I am on the home page of the website
  When I go to start a new group
  And I fill in and submit the form
  Then I should see the thank you page
  And I should recieve an email with an invitation link
  When I click the invitation link
  And I sign in to Loomio
  And I setup the group
  Then I should see the group page
