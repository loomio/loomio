describe 'Invitations', ->

  threadHelper = require './helpers/thread_helper.coffee'
  emailHelper = require './helpers/email_helper.coffee'
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

    describe 'by name', ->
      beforeEach ->
        invitationsHelper.openInvitationsModal()
        invitationsHelper.invite('max')
        invitationsHelper.submitInvitationsForm()

      it 'successfully invites the user', ->
        expect(groupsHelper.membersList().getText()).toContain('MVS')

      it 'displays the correct flash message', ->
        expect(groupsHelper.flashSection().getText()).toContain('1 member(s) added')

    describe 'by username', ->
      beforeEach ->
        invitationsHelper.openInvitationsModal()
        invitationsHelper.invite('ming')
        invitationsHelper.submitInvitationsForm()

      it 'successfully invites the user', ->
        expect(groupsHelper.membersList().getText()).toContain('MVS')

      it 'displays the correct flash message', ->
        expect(groupsHelper.flashSection().getText()).toContain('1 member(s) added')

    # describe 'inviting a group', ->
    #   beforeEach ->
    #     invitationsHelper.openInvitationsModal()
    #     invitationsHelper.invite('Point')
    #     invitationsHelper.submitInvitationsForm()

    #   it 'successfuly invites the group', ->
    #     expect(groupsHelper.flashSection().getText()).toContain('1 member(s) added')
    #     expect(groupsHelper.membersList().getText()).toContain('MVS')

    #   it 'displays the correct flash message', ->
    #     expect(groupsHelper.flashSection().getText()).toContain('1 member(s) added')

    describe 'by email address', ->
      beforeEach ->
        invitationsHelper.openInvitationsModal()
        invitationsHelper.invite('max@loomio.org')
        invitationsHelper.submitInvitationsForm()

      it 'successfully invites the user', ->
        expect(groupsHelper.membersList().getText()).toContain('MVS')

      it 'displays the correct flash message', ->
        expect(groupsHelper.flashSection().getText()).toContain('1 member(s) added')

  describe 'inviting a non-user', ->
    beforeEach ->
      invitationsHelper.load()

    describe 'by email address', ->
      beforeEach ->
        invitationsHelper.openInvitationsModal()
        invitationsHelper.invite('mollyringwald@loomio.org')
        invitationsHelper.submitInvitationsForm()

      it 'successfully invites someone', ->
        emailHelper.openLastEmail()
        expect(emailHelper.lastEmailSubject().getText()).toContain('Patrick Swayze has invited you to join Dirty Dancing Shoes on Loomio')

      it 'displays the correct flash message', ->
        expect(groupsHelper.flashSection().getText()).toContain('1 invitation(s) sent')

    describe 'inviting a contact', ->
      beforeEach ->
        invitationsHelper.openInvitationsModal()
        invitationsHelper.invite('keanu')
        invitationsHelper.submitInvitationsForm()

      it 'successfully invites a contact', ->
        emailHelper.openLastEmail()
        expect(emailHelper.lastEmailSubject().getText()).toContain('Dirty Dancing Shoes')

      it 'displays the correct flash message', ->
        expect(groupsHelper.flashSection().getText()).toContain('1 invitation(s) sent')

  describe 'inviting both users and non-user', ->
    beforeEach ->
      invitationsHelper.load()

    it 'successfully invites a contact', ->
      invitationsHelper.openInvitationsModal()
      invitationsHelper.invite('ming')
      invitationsHelper.invite('keanu')
      invitationsHelper.invite('mollyringwald@loomio.org')
      invitationsHelper.submitInvitationsForm()
      expect(groupsHelper.flashSection().getText()).toContain('1 member(s) added and 2 invitation(s) sent')
