Feature: Edit Memberships for a group
  As a group admin
  In order to remove members and modify admin status
  I need to manage the group memberships

  Scenario: Group Admin views memberships page for a group
    Given I am a signed in group admin
    When I view click edit memberships from the group page
    Then I should see the edit memberships page for the group
