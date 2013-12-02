Feature: Make subgroups of secret parents secret

Scenario:
Given there is a public subgroup of a secret group
When I migrate public subgroups of secret groups
Then the public subgroup should be secret