Feature: Public groups directory
  So that public groups can be found and viewed easily
  As a person
  I want to be able to see an index of public groups

  Background:
    Given there are various public and private groups

  Scenario: Person sees list of popular public groups
    When I visit the public groups directory page
    Then I should see all public groups sorted by popularity

  Scenario: Person searches for a group
    When I visit the public groups directory page
    And I search for a group
    Then I should see groups that match the search

  Scenario: Person sees featured groups
    When I visit the public groups directory page
    And I see featured groups separated from the list of groups
    And I click on the next page of results
    Then I should not see the featured groups

  @javascript
  Scenario: Person sorts by alphabetise
    When I visit the public groups directory page
    And I click the alphabetise icon
    Then I should see the list alphabetically sorted

    When I click the alphabetise icon again
    Then I should see the list sorted in reverse
