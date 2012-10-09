Feature: View group discussions
  To view all the discussions of a group including
  it's subgroups

Background:



Scenario: A user views a public group they are not a member of
  Given "green-group" is a public group
  Given I am not a member of "green-group"
  When I visit the group page for "green-group"
  Then I should see the discussions for "green-group"

Scenario: A user views a public group they are a member of
  Given "green-group" is a public group
  Given I am a member of "green-group"
  When I visit the group page for "green-group"
  Then I should see the discussions for "green-group"

Scenario: A user views a private group they are not a member of
  Given "red-group" is a private group
  Given I am not a member of "red-group"
  When I visit the group page for "red-group"
  Then I should not see the discussions for "red-group"

Scenario: A user views a private group they are a member of
  Given "red-group" is a private group
  Given I am a member of "red-group"
  When I visit the group page for "red-group"
  Then I should see the discussions for "red-group"


Scenario: A user views a public sub-group they are not a member of
  Given "green-group" is a public sub-group
  Given I am not a member of "green-group"
  When I visit the group page for "green-group"
  Then I should not see the discussions for "green-group"

Scenario: A user views a public sub-group they are a member of
  Given "green-group" is a public sub-group
  Given I am a member of "green-group"
  When I visit the group page for "green-group"
  Then I should see the discussions for "green-group"

Scenario: A user views a private sub-group they are not a member of
  Given "red-group" is a private sub-group
  Given I am not a member of "red-group"
  When I visit the group page for "red-group"
  Then I should not see the discussions for "red-group"

Scenario: A user views a private sub-group they are a member of



Scenario: A user views a group with a public sub-group, they are not a member of

Scenario: A user views a group with a public sub-group, they are a member of

Scenario: A user views a group with a private sub-group, they are not a member of

Scenario: A user views a group with a private sub-group, they are a member of

Scenario: A user views a group with a private sub-group, they are a member of and a private sub-group they are not a member of