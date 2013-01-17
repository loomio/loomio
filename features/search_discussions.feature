Feature: Search discussions 
  In order to efficiently find an existing discussion or decision
  A user must be able to filter the discussions list

Background:
  Given I am logged in
  And I am a member of a group
  And the group has discussions

Scenario: User enters a search term to filter discussions
  When I visit the group page
  Given the group has multiple discussions
  And the group has a discussion titled "Search"
  When I enter "Search" in the discussions search input
  Then I should only see discussions with "Search" in the title


