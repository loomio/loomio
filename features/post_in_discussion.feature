Feature: Post a comment in a discussion
To allow users to share their opinions
A user must be able to post comments in a discussion

Scenario: Post in discussion
Given I am logged in
And a group is created
And a discussion is created
And I am on the discussion page
When I write and submit a comment
Then a comment is added to the discussion