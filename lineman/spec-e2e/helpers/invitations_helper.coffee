module.exports = new class InvitationsHelper
  openInvitationModal: (group) ->
    element(By.css('.start-menu__start-button')).click()
    element(By.css('.start-menu__option[action=invitePeople] a')).click()

  groupDropdown: ->
    element(By.css('.invitation-form__group-dropdown'))

  groupDropdownSelectedOption: ->
    element(By.selectedOption('group'))

  invitableInput: ->
    element(By.css('.invitation-form__invitable-input'))

  selectInvitationGroup: ->

  enterInviteString: ->

  selectFirstInvitation: ->

  enterInvitationMessage: ->

  openInvitationModal: (group) ->
    @openInvitePeopleModal()
    @selectInvitationGroup(group)

  invite: (fragment) ->
    @enterInviteString(fragment)
    @selectFirstInvitation()

  submitInvitations: ->

          invitationHelper.openInvitationModal(group)
      expect(invitationHelper.groupDropdownSelectedOpen().getText()).toContain(group.name)
      expect(invitationHelper.invitableInput().isPresent()).toBe(true)
