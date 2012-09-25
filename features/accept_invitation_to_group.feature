Feature: User accepts invitation to Loomio group

  Scenario: New user is invited to Loomio group
    Given I have been sent an invite email to join a Loomio group
    When I click the invitation link
    Then I should see a page that explains that my group is using Loomio to make decisions
    And I should be asked to create an account or log-in
    When I create my user account
    Then I should become a member of the group
    And I should be taken to the group’s demo proposal page

  Scenario: Existing logged-out user is invited to Loomio group
    Given I am an existing Loomio user
    And I have been sent an invitation to join a Loomio group
    When I click the invitation link
    Then I should see a page that explains that my group is using Loomio to make decisions
    And I should be asked to create an account or log in
    When I log in
    Then I should become a member of the group
    And I should be taken to the group page

  Scenario: Existing logged-in user is invited to Loomio group
    Given I am an existing Loomio user
    And I am logged in
    And I have been sent an invitation to join a Loomio group
    When I click the invitation link
    Then I should become a member of the group
    And I should be taken to the group page
