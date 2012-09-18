Feature: Change Username
In order to allow users to feel at home
we allow them to change their usernames.

Scenario: Successful Change
Given I am logged in
When I am on the settings page
And I enter my desired username
And the username is not taken
Then my username is changed

Scenario: Change to original username
Given I am logged in
When I am on the settings page
And I enter my current username
Then my username stays the same

Scenario: Attempt to change to taken username
Given I am logged in
When I am on the settings page
And I enter my desired username
And the username is taken
Then my username is not changed