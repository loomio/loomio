Feature: Following UI

Background:
  Given I am the logged in admin of a group
  And I have set my preferences to email me activity I'm following

Scenario: Following a group
  Given I am not following the group
  When I click "Not following" on the group page
  Then I should be following new discussions by default

Scenario: Unfollowing a group
  Given I am following the group
  When I click "Following" on the group page
  Then I should not be following discussions by default

Scenario: New discussion in followed group
  Given I am following the group
  When there is a new discussion in the group
  Then I should get an email about the new discussion

Scenario: New discussion in unfollowed group
  Given I am not following the group
  When there is a new discussion in the group
  Then I should not get an email about the new discussion

Scenario: Being mentioned in a discussion I've never seen
  Given there is a discussion I have never seen before
  And I get mentioned in a discussion
  Then I should be emailed the comment

Scenario: Being mentioned in a discussion I've unfollowed
  Given there is a discussion I have unfollowed
  And I get mentioned in a discussion
  Then I should be emailed the comment

Scenario: New activity in a followed discussion
  Given there is a discussion I am following
  When there is a subsequent comment in the discussion
  Then I should be emailed the comment

Scenario: Unfollowing a discussion
  Given there is a discussion I am following
  And I click 'Following' on the discussion page
  When there is a subsequent comment in the discussion
  Then I should not get emailed the comment

Scenario: Following a discussion
  Given there is a discussion I not following
  And I click 'Not Following' on the discussion page
  When there is a subsequent comment in the discussion
  Then I should be emailed the comment

Scenario: Viewing followed content on my dashboard
  Given there is a discussion I am not following
  And there is a discussion I am following
  When I am on the dashboard
  Then I should see both discussions
  When I filter to only show followed content
  Then I should only see the followed discussion
