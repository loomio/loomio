Feature: Pay what you can
  As a Loomio user
  So that I can support the project
  I would like to pay a monetary contribution to Loomio

  Scenario: Signed out user attempts to make a contribution
    When I visit the pay what you can page
    Then I be should be redirected to the sign in page

  @javascript
  Scenario: Signed in user visits contibute page
    Given I am logged in
    And I am not a member of a paying group
    When I click the contribute icon
    Then I should see the contribution page
    
  Scenario: Member of paying group does not see payment icon
    Given I am logged in
    And I am a member of a paying group
    And I visit the group page
    Then I do not see the pay what you can icon in the navbar

