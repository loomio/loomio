Feature: Email group members
  As a group admin
  So that I communicate with my group efficiently
  I want to be able to send a group email

  @javascript
  Scenario: Group Admin sends group email
    Given I am logged in
    And I am an admin of a group
    When I visit my group's memberships index
    And I email the group members
    Then memberships should get an email with subject "made an announcement"
