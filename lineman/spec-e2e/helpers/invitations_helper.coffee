module.exports = new class InvitationsHelper
  openInvitationsModal: (group) ->
    element(By.css('.start-menu__start-button')).click()
    element(By.css('.start-menu__option[action=invitePeople] a')).click()

  groupDropdown: ->
    element(By.css('.invitation-form__group-dropdown'))

  invitableInput: ->
    element(By.css('.invitation-form__invitable-input'))

  # selectInvitationGroup: ->

  # enterInviteString: ->

  # selectFirstInvitation: ->

  # enterInvitationMessage: ->

  # invite: (fragment) ->
  #   @enterInviteString(fragment)
  #   @selectFirstInvitation()

  # submitInvitations: ->
