Feature: Public groups directory
  So that public groups can be found and viewed easily
  As a non-meber
  I want to be able to see an index of public groups

  Scenario: non-member visits the public group directory
    When I visit the public groups directory page
    # When I visit the Loomio homepage
    # And I click the link to the public groups directory
    Then I should see the public groups directory page

  Scenario: non-member searches for a group
    Given there are various public and private groups
    When I visit the public groups directory page
    And I type part of the group name I am looking for into the search box
    Then I should only see groups that match my search in the list
    And I should not see private groups
