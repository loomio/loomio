Feature: Create Group
In order to allow users make decisions as a collective
Users must be able to create groups

Scenario: Create public, open invite Group as Group Admin
Given I am logged in
When I click create group
And I select public, open invite
And I fill in the group details
Then a new group is created

Scenario: Create private, open invite Group as Group Admin
Given I am logged in
When I click create group
And I select private, open invite
And I fill in the group details
Then a new group is created

Scenario: Create public, member-only invite Group as Group Admin
Given I am logged in
When I click create group
And I select public, member-only
And I fill in the group details
Then a new group is created

Scenario: Create private, member-only invite Group as Group Admin
Given I am logged in
When I click create group
And I select private, member-only
And I fill in the group details
Then a new group is created