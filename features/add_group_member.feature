Feature: Add member to group
To allow multiple pleople to make decisions as a collective
Users must be able to be added to groups

Scenario: Add group member
Given I am logged in
And a group is created
And I am an admin of the group
When I complete an invitation
And no such member already exists
Then a member is added to the group