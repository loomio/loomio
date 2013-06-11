Feature: Edit Memberships for a group
  As a group admin
  In order to remove members and modify admin status
  I need to manage the group memberships

  Scenario: Group Admin views memberships page for a group
    Given I am a signed in group admin
    When I view click edit memberships from the group page
    Then I should see the edit memberships page for the group

  Scenario: Group Admin promotes another group member to admin
    Given I am a signed in group admin
    And there is another group member
    When I view click edit memberships from the group page
    And click 'Make admin' on the member
    Then the member should be a group admin
    And I should see the edit memberships page

  Scenario: Group Admin removes admin from another member
    Given I am a signed in group admin
    And there is another group admin
    When I view click edit memberships from the group page
    And click 'Remove admin' on the member
    Then the member should no longer be a group admin
    And I should see the edit memberships page

  Scenario: Group Admin removes another member from the group
    Given I am a signed in group admin
    And there is another group member
    When I view click edit memberships from the group page
    And click 'Remove' on the member
    Then the member should no longer belong to the group
    And I should see the edit memberships page

