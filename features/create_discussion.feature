Feature: Create discussion
To allow users to share their opinions
A user must be able to start a discussion

Scenario: Create discusiion
Given I am logged in
And a group is created
When I visit the create discussion page
And fill in discussion details
Then a discussion is created