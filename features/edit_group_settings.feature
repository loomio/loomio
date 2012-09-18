Feature: Edit group settings
In order for groups to be customized to suit the users' needs
Administrators of a group must be able to edit group settings

Scenario: Non-admin cannot edit group settings
Given I am logged in
And a group is created
And I am a member of the group
Then I should not have access to group settings

Scenario: Change group visibility to public
Given I am logged in
And a group is created
And I am an admin of the group
When I visit the group settings page
And I update the settings to public
Then the group should be public

Scenario: Change group visibility to Members only
Given I am logged in
And a group is created
And I am an admin of the group
When I visit the group settings page
And I update the settings to members only
Then the group should be private

Scenario: Change group name
Given I am logged in
And a group is created
And I am an admin of the group
When I visit the group settings page
And I update the group name
Then the group name is changed

Scenario: Change group invitations to allow all members
Given I am logged in
And a group is created
And I am an admin of the group
When I visit the group settings page
And I update the invitations to allow all members
Then all members should be able to invite other users

Scenario: Change group invitations to allow only admin
Given I am logged in
And a group is created
And I am an admin of the group
When I visit the group settings page
And I update the invitations to allow only admin
Then only admin should be able to invite other users