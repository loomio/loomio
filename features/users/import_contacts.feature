Feature: Import contacts
  So that I can invite people to my group by name.
  I want to import my contacts from my online addressbooks

  Scenario: Import Gmail contacts
    Given I am logged in and belong to a group
    When I visit the import contacts page
    And I import my gmail contacts
    Then I should have some contacts
