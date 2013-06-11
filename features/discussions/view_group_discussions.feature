Feature: User views group discussions
  As a Loomio user
  So that I can see what groups are discussing
  I want to see all the public discussions belonging to a group

@javascript
Scenario: Group member views discussions for a public group
  Given I am logged in
  And I am a member of a public group
  And the group has discussions
  When I visit the group page
  Then I should see the group's discussions

@javascript
Scenario: Group non-member views discussions for a public group
  Given I am logged in
  And a public group exists that I am not a member of
  And the group has discussions
  When I visit the group page
  Then I should see the group's discussions

@javascript
Scenario: Group member views discussions for a private group
  Given I am logged in
  And I am a member of a private group
  And the group has discussions
  When I visit the group page
  Then I should see the group's discussions

@javascript
Scenario: Group non-member tries to view discussions for a private group
  Given I am logged in
  And a private group exists that I am not a member of
  And the group has discussions
  When I visit the group page
  Then I should not see the group's discussions

@javascript
Scenario: Sub-group member views discussions for a public sub-group
  Given I am logged in
  And I am a member of a public sub-group
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions
  When I visit the parent-group page
  Then I should see the sub-group's discussions

@javascript
Scenario: Sub-group non-member views discussions for a public sub-group
  Given I am logged in
  And a public sub-group exists that I am not a member of
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions
  When I visit the parent-group page
  Then I should see the sub-group's discussions

@javascript
Scenario: Sub-group member views discussions for a private sub-group
  Given I am logged in
  And I am a member of a private sub-group
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions
  When I visit the parent-group page
  Then I should see the sub-group's discussions

@javascript
Scenario: Sub-group non-member tries to view discussions for a private sub-group
  Given I am logged in
  And a private sub-group exists that I am not a member of
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should not see the sub-group's discussions
  When I visit the parent-group page
  Then I should not see the sub-group's discussions


@javascript
Scenario: Sub-group member views discussions for a visible-to-parent sub-group
  Given I am logged in
  And I am a member of a sub-group viewable by parent-group members
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions


@javascript
Scenario: Parent-group member views discussions for a sub-group viewable by parent-group members
  Given I am logged in
  And I am a member of a parent-group that has a sub-group viewable by parent-group members
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions
  When I visit the parent-group page
  Then I should not see the sub-group's discussions

@javascript
Scenario: Parent-group non-member tries to view discussions for a sub-group viewable by parent-group members
  Given I am logged in
  And I am not a member of a parent-group that has a sub-group viewable by parent-group members
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should not see the sub-group's discussions
