Feature: Migrate devise invitable users to invitations
  In order to ensure old invitation links work
  We need to redirect the old links to the new place
  And migrate the old users into invitations

  Scenario: User invited by devise gets migrated to invitation
    Given there is a user account created by devise invitable
    When I migrate the devise invited users to invitations
    Then there should be an invitation with the same token, group and inviter

  Scenario: Destroy old invited users
    When I destroy the old invited users
    Then the users should be destroyed

  Scenario: Old invitation link redirects to new invitation path
    When I load a devise invitation link
    Then I should be redirected to the appropriate invitation path
