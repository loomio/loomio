Feature: User is invited to start a group on loomio
  In order to allow users to start groups on loomio
  And set them up properly
  We do this

  Scenario: Admin accepts new group request
    Given there is a verified group request
    And I am a logged in site admin
    When I approve the group request and send the setup invitation
    Then the requestor should get an invitation to start a loomio group

  @wip
  Scenario: New user accepts invitiation to start a loomio group
    Given an invitiation to start a loomio group has been sent
    When the user clicks the invitiation link
    And signs up as a new user
    Then they should see the Start your Group wizard

  Scenario: Group Admin configures new group with the Start Your Group Wizard
    Given I am a signed in admin of an unconfigured group
    # I wonder if we should redirect them.. or what..
    When I visit the setup_new_group_wizard path
    And enter a group name and description
    And create a discussion and proposal
    And invite other users to join the group
    Then the group should be configured
