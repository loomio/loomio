Feature: User views chronologically ordered discussion
  As a User
  I want to see disucussion in chronological order
  So that I can easily start reading a discussion

Background:
  Given I am logged in
  And there is a discussion in a group I belong to
  And discussions per page is 50

@javascript
Scenario: User views discussion in chronological order
  Given there are two comments
  When I visit the discussion page
  Then I should see the comments in order of creation
  And I should not see the new activity indicator
  And I should see the add comment input

@javascript
Scenario: User adds new content and does not see the new activity indicator
  When I visit the discussion page
  And I choose to edit the discussion description
  And I fill in and submit the discussion description form
  Then I should not see the new activity indicator

@javascript
Scenario: User returns to discussion after new activity
  Given there is a discussion that I have previously viewed
  And there has been new activity
  When I visit the discussion page
  Then I should see the new activity indicator

@javascript
Scenario: User returns to long discussion and is brought to last read point
  Given there is a two page discussion
  And I have previously viewed the second page of the discussion
  And now there is new activity
  When I visit the discussion page
  Then I should see the second page
  And I should see the new activity indicator

@javascript
Scenario: User only sees add comment input on last page
  Given there is a two page discussion
  And I visit the discussion page
  And I don't see the add comment input
  Then I visit the last page of the discussion
  And I should see the add comment input
