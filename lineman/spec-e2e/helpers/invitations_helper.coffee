module.exports = new class InvitationsHelper
  load: ->
    browser.get('http://localhost:8000/development/setup_group_for_invitations')

  loadPending: ->
    browser.get('http://localhost:8000/development/setup_group_with_pending_invitation')

  openInvitationsModal: (group) ->
    element(By.css('.start-menu__start-button')).click()
    element(By.css('.start-menu__option[action=invitePeople] a')).click()

  groupDropdown: ->
    element(By.css('.invitation-form__group-dropdown'))

  invitableInput: ->
    element(By.css('.invitation-form__invitable-input'))

  invite: (fragment) ->
    @invitableInput().clear().sendKeys(fragment)
    element.all(By.css('.invitation-form__invitable')).first().click()

  submitInvitationsForm: ->
    element(By.css('.invitation-form__submit')).click()

  clickManageMembers: ->
    element(By.css('.members-card__manage-members a')).click()

  pendingInvitationsPanel: ->
    element(By.css('.pending-invitations-card'))

  pendingInvitationEmail: ->
    element(By.css('.pending-invitations-card__recipient-email'))

  pendingInvitationUrl: ->
    element(By.css('.pending-invitations-card__invitation-url'))

  cancelPendingInvitation: ->
    element(By.css('.pending-invitations-card__cancel-link')).click()
    element(By.css('.cancel-invitation-form__submit')).click()

  clickAddCustomMessageLink: ->
    element(By.css('.invitation-form__add-message-button')).click()

  customMessageField: ->
    element(By.css('.invitation-form__message-input'))
