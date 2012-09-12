Feature: Add member to group
To allow multiple pleople to make decisions as a collective
Users must be able to be added to groups

Scenario: Add group member
Given I am logged in
And a group is created
And I am an admin of the group
And there exists a user to add to the group
When no such user is already in the group
And I complete an invitation
Then a member is added to the group

Scenario: Add group member that is already in the group
Given I am logged in
And a group is created
And I am an admin of the group
And there is a user in the group
And I complete an invitation
Then a member is not added to the group