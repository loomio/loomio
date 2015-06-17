describe 'Invitations', ->

  threadHelper = require './helpers/thread_helper.coffee'
  invitationsHelper = require './helpers/invitations_helper.coffee'
  groupsHelper = require './helpers/groups_helper.coffee'

  describe 'basics', ->
    it 'successfully opens a modal', ->
      threadHelper.load()
      invitationsHelper.openInvitationsModal()
      expect(invitationsHelper.groupDropdown().isPresent()).toBe(true)

    it 'successfully opens a model for a specific group', ->
      groupsHelper.load()
      invitationsHelper.openInvitationsModal()
      expect(invitationsHelper.groupDropdown().getText()).toContain('Dirty')
      expect(invitationsHelper.invitableInput().isPresent()).toBe(true)

  describe 'inviting a Loomio user', ->

    beforeEach ->
      invitationsHelper.load()

    it 'successfully invites a user by name', ->
      invitationsHelper.openInvitationsModal()
      invitationsHelper.invite('max')
      invitationsHelper.submitInvitationsForm()
      expect(groupsHelper.membersList().getText()).toContain('MVS')

    it 'successfully invites a user by username', ->
      invitationsHelper.openInvitationsModal()
      invitationsHelper.invite('ming')
      invitationsHelper.submitInvitationsForm()
      expect(groupsHelper.membersList().getText()).toContain('MVS')

    it 'successfuly invites a group', ->
      invitationsHelper.openInvitationsModal()
      invitationsHelper.invite('Point')
      invitationsHelper.submitInvitationsForm()
      expect(groupsHelper.membersList().getText()).toContain('MVS')

    # it 'successfully invites a contact', ->
    #   invitationsHelper.openInvitationsModal()
    #   invitationsHelper.invite('keanu')
    #   invitationsHelper.submitInvitationsForm()
