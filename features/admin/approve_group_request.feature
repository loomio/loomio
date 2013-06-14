Feature: Loomio admin approves group request to join Loomio
  As a Loomio super-admin
  So that I can moderate the growth of the Loomio userbase
  I want to be able to approve group applications

  Background:
    Given I am a Loomio super-admin
    And I am logged in
    And there is a verified request to join Loomio

  @javascript
  Scenario: Loomio admin sets the maximum group size
    When I visit the Group Request in the admin panel
    And I edit the maximum group size
    Then the maximum group size should be assigned to the group

  @javascript
  Scenario: Loomio admin approves a group request
    When I visit the admin Group Requests index
    And I click approve for a request
    And I should see the send approval email page
    And I customise the approval email text
    And I click the send and approve button
    Then the group request should be marked as approved
    And the group should be created
    And an email should be sent to the group admin with an invitation link
    And I should be redirected to the Group Requests page
    And I should no longer see the request
