Feature: Create Group
In order to allow users make decisions as a collective
Users must be able to create groups

Scenario: Create Group as Group Admin
Given I am logged in
When I click create group
And I fill in the group details
Then a new group is created