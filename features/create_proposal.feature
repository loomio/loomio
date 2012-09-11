Feature: Create Proposal
In order to make the site a productive place
Users must be able to create proposals


Scenario: Create Proposal as Group User
Given I am logged in
When I am on a group page
And I click create proposal
And fill in the proposal details
Then a new proposal is created


Scenario: Create Proposal as Group Admin
Given I am logged in
And group admin
And on group page
When I click create proposal
And fill in the proposal details
Then a new proposal is created
