  Feature: User views group discussions
  As a Loomio user
  So that I can see what groups are discussing
  I want to see all the public discussions belonging to a group


Scenario: Group member views discussions for a public group
  Given I am logged in
  And I am a member of a public group
  And the group has discussions
  When I visit the group page
  Then I should see the group's discussions

Scenario: Group non-member views discussions for a public group
  Given I am logged in
  And I am not a member of a public group
  And the group has discussions
  When I visit the group page
  Then I should see the group's discussions

Scenario: Group member views discussions for a private group
  Given I am logged in
  And I am a member of a private group
  And the group has discussions
  When I visit the group page
  Then I should see the group's discussions

Scenario: Group non-member tries to view discussions for a private group
  Given I am logged in
  And I am not a member of a private group
  And the group has discussions
  When I visit the group page
  Then I should not see the group's discussions


Scenario: Sub-group member views discussions for a public sub-group
  Given I am logged in
  And I am a member of a public sub-group
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions

Scenario: Sub-group non-member views discussions for a public sub-group
  Given I am logged in
  And I am not a member of a public sub-group
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions

Scenario: Sub-group member views discussions for a private sub-group
  Given I am logged in
  And I am a member of a private sub-group
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions

Scenario: Sub-group non-member tries to view discussions for a private sub-group
  Given I am logged in
  And I am not a member of a private sub-group
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should not see the sub-group's discussions

Scenario: Sub-group member views discussions for a sub-group viewable by parent-group members
  Given I am logged in
  And I am a member of a sub-group viewable by parent-group members
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions

Scenario: Parent-group member views discussions for a sub-group viewable by parent-group members
  Given I am logged in
  And I am a member of a parent-group that has a sub-group viewable by parent-group members
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should see the sub-group's discussions

Scenario: Parent-group non-member tries to view discussions for a sub-group viewable by parent-group members
  Given I am logged in
  And I am not a member of a parent-group that has a sub-group viewable by parent-group members
  And the sub-group has discussions
  When I visit the sub-group page
  Then I should not see the sub-group's discussions



Scenario: Public sub-group member views discussions for its parent-group, and sees the sub-group's discussions
  Given I am logged in
  And I am a member of a public sub-group
  And the sub-group has discussions
  When I visit the parent-group page
  Then I should see the sub-group's discussions

Scenario: Public sub-group non-member views discussions for its parent-group, and sees the sub-group's discussions
  Given I am logged in
  And I am not a member of a public sub-group
  And the sub-group has discussions
  When I visit the parent-group page
  Then I should see the sub-group's discussions

Scenario: Private sub-group member views discussions for its parent-group, and sees the sub-group's discussions
  Given I am logged in
  And I am a member of a private sub-group
  And the sub-group has discussions
  When I visit the parent-group page
  Then I should see the sub-group's discussions

Scenario: Private sub-group non-member views discussions for its parent-group, and does not see the sub-group's discussions
  Given I am logged in
  And I am not a member of a private sub-group
  And the sub-group has discussions
  When I visit the parent-group page
  Then I should not see the sub-group's discussions

Scenario: Parent-group member views discussions for parent-group with a sub-group viewable to parent-group members, and does not see the sub-group's discussions
  Given I am logged in
  And I am a member of a parent-group that has a sub-group viewable by parent-group members
  And the sub-group has discussions
  When I visit the parent-group page
  Then I should not see the sub-group's discussions

Scenario: Parent-group non-member views discussions for parent-group with a sub-group viewable to parent-group members, and does not see the sub-group's discussions
  Given I am logged in
  And I am not a member of a parent-group that has a sub-group viewable by parent-group members
  And the sub-group has discussions
  When I visit the parent-group page
  Then I should not see the sub-group's discussions
