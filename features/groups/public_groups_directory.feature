Feature: Public groups directory
  So that public groups can be found and viewed easily
  As a person
  I want to be able to see an index of public groups

  Background:
    Given there are various public and private groups

  Scenario: Person sees list of public groups
    When I visit the public groups directory page
    Then I should only see public groups with 5 or more members

  Scenario: Person searches for a group
    When I visit the public groups directory page
    And I search
    Then I should only see groups that match the search
