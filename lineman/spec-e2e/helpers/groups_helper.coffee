module.exports = new class GroupsHelper
  load: ->
    browser.get('http://localhost:8000/development/setup_group')

  membersList: ->
    element(By.css('.group-member-list'))

  clickStartDiscussionBtn: ->
    element(By.css('.group-page__new-thread a')).click()

  fillInDiscussionTitle: (title)->
    element(By.css('.discussion-form__title-input')).sendKeys(title)

  fillInDiscussionDescription: (description) ->
    element(By.css('.discussion-form__description-input')).sendKeys(description)

  submitDiscussionForm: ->
    element(By.css('.discussion-form__submit')).click()

  discussionTitle: ->
    element(By.css('.thread-context'))

  openOptionsDropdown: ->
    element(By.css('.group-page-actions button')).click()

  clickEditGroupOption: ->
    element(By.css('.group-page-actions__edit-group-link')).click()

  changeGroupVisibilitySettings: ->
    element(By.css('.edit-group-form__group-visible-to-field option[value=members]')).click()

  # changeGroupPermissionsOptions: ->
  #   element(By.css('.edit-group-form__group-members-can-add-members')).click()
  #   element(By.css('.edit-group-form__group-members-can-create-subgroups')).click()
  #   element(By.css('.edit-group-form__group-members-can-start-discussions')).click()
  #   element(By.css('.edit-group-form__group-members-can-edit-discussions')).click()
  #   element(By.css('.edit-group-form__group-members-can-edit-comments')).click()
  #   element(By.css('.edit-group-form__group-members-can-raise-motions')).click()

  visitEditGroupPage: ->
    @openOptionsDropdown()
    @clickEditGroupOption()

  votePermissionsCheckbox: ->
    element(By.css('.edit-group-form__group-members-can-vote'))

  changeVotingPermissions: ->
    @votePermissionsCheckbox().click()

  submitGroupSettingsForm: ->
    element(By.css('.edit-group-form__submit-button')).click()

  groupPage: ->
    element(By.css('.group-page'))
