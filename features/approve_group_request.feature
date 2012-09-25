Feature: Admin approves group request to join Loomio
  As a Loomio super-admin
  So that I can moderate the growth of the Loomio userbase
  I want to be able to approve group applications

  Scenario: Admin views group requests
    Given I am a Loomio super-admin
    And there is a request to join Loomio
    When I visit the Group Requests page on the admin panel
    Then I should see the request

  Scenario: Admin approves a group request
    Given I am a Loomio super-admin
    And there is a request to join Loomio
    When I visit the Group Requests page on the admin panel
    And I approve approve the request
    Then the group should be created
    And invitation links should be sent to every email address
    And I should be redirected to the Group Requests page
