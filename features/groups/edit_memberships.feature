Feature: Edit memberships for a group
  As a group admin
  In order to remove members and modify admin status
  I need to manage the group memberships

  Scenario: Group member views memberships index
    Given I am logged in
    And I am a member of a group
    When I visit the group page
    And I click 'More'
    Then I should see the memberships index

  Scenario: Group Admin promotes another group member to admin
    Given I am a signed in group admin
    And there is another group member
    When I visit my group's memberships index
    And click 'Make coordinator' on the member
    Then the member should be a group admin
    And I should see the memberships index

  Scenario: Group Admin removes admin from another member
    Given I am a signed in group admin
    And there is another group admin
    When I visit my group's memberships index
    And click 'Remove coordinator' on the member
    Then the member should no longer be a group admin
    And I should see the memberships index

  Scenario: Group Admin removes another member from the group
    Given I am a signed in group admin
    And there is another group member
    When I visit my group's memberships index
    And click 'Remove' on the member
    Then the member should no longer belong to the group
    And I should see the memberships index

