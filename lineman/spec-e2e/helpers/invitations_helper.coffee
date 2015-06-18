module.exports = new class InvitationsHelper
  load: ->
    browser.get('http://localhost:8000/development/setup_group_for_invitations')

  openInvitationsModal: (group) ->
    element(By.css('.start-menu__start-button')).click()
    element(By.css('.start-menu__option[action=invitePeople] a')).click()

  groupDropdown: ->
    element(By.css('.invitation-form__group-dropdown'))

  invitableInput: ->
    element(By.css('.invitation-form__invitable-input'))

  invite: (fragment) ->
    @invitableInput().clear().sendKeys(fragment)
    element(By.css('.invitation-form__invitable')).click()

  submitInvitationsForm: ->
    element(By.css('.invitation-form__submit')).click()
