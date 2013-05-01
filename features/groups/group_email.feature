Feature: User requests to join group
  As a group admin
  So that I communicate with my group efficiently
  I want to be able to send a group email

  Scenario: Group Admin sends group email
    Given I am logged in
    And I am an admin of a group
    When I visit the group page
    Then I email the group members
    And memberships should get an email with subject "made an announcement"
