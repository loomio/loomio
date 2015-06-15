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

  # describe 'inviting a Loomio user', ->

  #   beforeEach ->
  #     threadHelper.load()

  #   it 'successfully invites a user by name', ->
  #     invitationsHelper.openInvitationModal(group)
  #     invitationsHelper.invite('hannah')
  #     invitationsHelper.submitInvitationForm()
