Feature: Admin approves group request to join Loomio
  As a Loomio super-admin
  So that I can moderate the growth of the Loomio userbase
  I want to be able to approve group applications

  Background:
    Given I am a Loomio super-admin
    And I am logged in
    And there is a request to join Loomio

  Scenario: Admin views group requests
    When I visit the Group Requests page on the admin panel
    Then I should see the request

  Scenario: Admin approves a group request
    When I visit the Group Requests page on the admin panel
    And I approve the request
    Then the group request should be marked as approved
    And the group should be created
    And an invitation email should be sent to the admin
    And I should be redirected to the Group Requests page
    And I should no longer see the request

  Scenario: Admin ignore a group request
    When I visit the Group Requests page on the admin panel
    And I ignore the request
    Then the group request should be marked as ignored
    And I should be redirected to the Group Requests page
    And I should no longer see the request
