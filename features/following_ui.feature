Feature: Following UI

Background:
  Given I am the logged in admin of a group
  And I have set my preferences to email me activity I'm following

Scenario: Following a group
  Given I am not following the group
  And I click follow on the group page
  When there is a new discussion in the group
  Then I should get an email about it

Scenario: Unfollowing a group
  Given I am following the group
  And I click unfollow on the group page
  When there is a new discussion in the group
  Then I should not get an email about it

Scenario: Being mentioned in a discussion
  Given there is an discussion I am not following
  And I get mentioned in a discussion
  Then I should get emailed because I was mentioned

Scenario: New activity in a followed discussion
  Given there is a discussion I am following
  When there is a subsequent comment in the discussion
  Then I should be emailed the comment

Scenario: Unfollowing a discussion
  Given there is a discussion I am following
  And I click unfollow on the discussion page
  When there is a subsequent comment in the discussion
  Then I should not get emailed the comment

Scenario: Viewing followed content on my dashboard
  Given there is a discussion I am not following
  And there is a discussion I am following
  When I am on the dashboard
  Then I should see both discussions
  When I filter to only show followed content
  Then I should only see the followed discussion
