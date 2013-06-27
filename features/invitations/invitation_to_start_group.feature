Feature: User is invited to start a group on loomio
  In order to allow users to start groups on loomio
  And set them up properly
  We do this

  Scenario: Admin accepts new group request
    Given there is a verified group request
    And I am a logged in site admin
    When I approve the group request and send the setup invitation
    Then the requestor should get an invitation to start a loomio group

  Scenario: New user accepts invitiation to start a loomio group
    Given an invitiation to start a loomio group has been sent
    When the user clicks the invitiation link
    And they sign up as a new user speaking "Español"
    Then they should be redirected to the group setup wizard
    And they should see "Grupo"
