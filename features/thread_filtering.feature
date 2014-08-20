Feature: Dashboard filtering

Background:
  Given a group with an existing thread

Scenario: Old activity does not show up in followed threads
  When I join and follow the group
  Then I should not see anything in my followed threads

Scenario: New thread in followed group shows up in followed threads
  When there is a new thread started in the group I'm following
  Then I should see the thread in my followed threads
  And  I should see the thread in my unread threads

Scenario: New comment in followed thread shows up in followed threads
  When there is a new comment in a thread in the group
  Then I should see the thread in my followed threads
  And  I should see the thread in my unread threads

Scenario: Old activity does not show up in unread threads
  When I join and follow the group
  Then I should not see anything in my unread threads
  But the unread count for the thread should be correct