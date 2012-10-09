Feature: User views group discussions
  As a Loomio user
  So that I can see what groups are discussing
  I want to see all the public discussions belonging to a group


Scenario: User views discussions for a public group they are a member of
  Given "green-group" is a public group
  Given I am a member of "green-group"
  When I visit the group page for "green-group"
  Then I should see the discussions for "green-group"

Scenario: User views discussions for a public group they are not a member of
  Given "green-group" is a public group
  Given I am not a member of "green-group"
  When I visit the group page for "green-group"
  Then I should see the discussions for "green-group"

Scenario: User views discussions for a private group they are a member of
  Given "red-group" is a private group
  Given I am a member of "red-group"
  When I visit the group page for "red-group"
  Then I should see the discussions for "red-group"

Scenario: User tries to view discussions for a private group they are not a member of
  Given "red-group" is a private group
  Given I am not a member of "red-group"
  When I visit the group page for "red-group"
  Then I should not see the discussions for "red-group"



Scenario: User views discussions for a public sub-group they are a member of

Scenario: User views discussions for a public sub-group they are not a member of

Scenario: User views discussions for a private sub-group they are a member of

Scenario: User tries to view discussions for a private sub-group they are not a member of

Scenario: User views discussions for a sub-group viewable by parent-group members and they are a sub-group member

Scenario: User views discussions for a sub-group viewable by parent-group members and they are a parent-group member

Scenario: User tries to view discussions for a sub-group viewable by parent-group members and they are not a sub-group or parent-group member



Scenario: User views a discussions for a group with a public sub-group, they are not a member of

Scenario: A user views a group with a public sub-group, they are a member of

Scenario: A user views a group with a private sub-group, they are not a member of

Scenario: A user views a group with a private sub-group, they are a member of

Scenario: A user views a group with a private sub-group, they are a member of and a private sub-group they are not a member of