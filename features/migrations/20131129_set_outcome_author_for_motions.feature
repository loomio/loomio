Feature: migrate motions with outcomes to give them outcome authors

Scenario: Motion with outcome but no outcome author gets outcome author assigned

Given there is a motion with an outcome but no author
When I run the set_motion_outcome_author migration
Then that motion now has a motion author
