Feature: Pay what you can
  As a Loomio user
  So that I can support the project
  I would like to pay a monetary contribution to Loomio

  @javascript
  Scenario: Signed in user visits contibute page (pwyc member)
    Given I am logged in
    And I am a member of a pwyc group
    When I click the contribute icon
    Then I should see the contribution page

  @javascript
  Scenario: Signed in user visits contibute page
    Given I am logged in
    And I am a member of a group with an undetermined payment plan
    When I click the contribute icon
    Then I should see the contribution page

  Scenario: Member of paying group does not see payment icon
    Given I am logged in
    And I am a member of a paying group
    And I visit the group page
    Then I do not see the pay what you can icon in the navbar

