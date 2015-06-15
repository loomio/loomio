describe 'Invitations', ->

  threadHelper = require './helpers/thread_helper.coffee'
  invitationsHelper = require './helpers/invitation_helper.coffee'

  describe 'basics', ->
    it 'successfully opens a modal', ->
      invitationHelper.openInvitationModal()
      expect(invitationHelper.groupDropdown().isPresent()).toBe(true)

    # it 'successfully opens a model for a specific group', ->
    #   invitationHelper.openInvitationModal(group)
    #   expect(invitationHelper.groupDropdownSelectedOption().getText()).toContain(group.name)
    #   expect(invitationHelper.invitableInput().isPresent()).toBe(true)

  # describe 'inviting a Loomio user', ->

  #   beforeEach ->
  #     threadHelper.load()

  #   it 'successfully invites a user by name', ->
  #     invitationHelper.openInvitationModal(group)
  #     invitationHelper.invite('hannah')
  #     invitationHelper.submitInvitationForm()
