Feature: Public groups directory
  So that public groups can be found and viewed easily
  As a person
  I want to be able to see an index of public groups

  Background:
    Given there are various public and private groups

    # Scenario: Person sees featured groups
    #   When I visit the home page
    #   Then I should see the featured groups

    Scenario: Person sees sorted list of public groups
      When I visit the public groups directory page
      Then I should see all public groups sorted by popularity

    Scenario: Person searches for a group
      When I visit the public groups directory page
      And I search for a group
      Then I should see groups that match the search
