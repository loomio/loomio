Feature: Start new group
  In order to bring my group onto Loomio
  As a group coordinator
  I want to create a new group

Background:
  And There are default group covers available

Scenario: Guest submits invalid start group form
  Given I click 'Try Loomio' from the front page
  When I go to start a new group
  And I click start group without filling in any fields
  Then I should see the start group form with errors
