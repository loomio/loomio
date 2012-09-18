Feature: Like post
In order for users to show their appreciation for other users' posts
A user must be able to like a post

Scenario: Like post
Given I am logged in
And a group is created
And a discussion is created
And I am on the discussion page
And a comment is added to the discussion
When I click the like button on a post
Then a post is liked