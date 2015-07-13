module.exports = new class GroupsHelper
  load: ->
    browser.get('http://localhost:8000/development/setup_group')

  loadToJoin: (value) ->
    browser.get("http://localhost:8000/development/setup_group_to_join?membership_granted_upon=#{value}")

  loadWithMultipleCoordinators: ->
    browser.get('http://localhost:8000/development/setup_group_with_multiple_coordinators')

  flashSection: ->
    element(By.css('.flash-message'))

  membersList: ->
    element(By.css('.group-page-members'))

  startThreadButton: ->
    element(By.css('.group-page__new-thread a'))

  clickStartThreadButton: ->
    @startThreadButton().click()

  fillInDiscussionTitle: (title)->
    element(By.css('.discussion-form__title-input')).sendKeys(title)

  fillInDiscussionDescription: (description) ->
    element(By.css('.discussion-form__description-input')).sendKeys(description)

  submitDiscussionForm: ->
    element.all(By.css('.discussion-form__submit')).first().click()

  discussionTitle: ->
    element(By.css('.thread-context'))

  memberOptionsDropdown: ->
    element(By.css('.group-page-actions button'))

  openMemberOptionsDropdown: ->
    @memberOptionsDropdown().click()

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
    @openMemberOptionsDropdown()
    @clickEditGroupOption()

  votePermissionsCheckbox: ->
    element(By.css('.edit-group-form__group-members-can-vote'))

  changeVotingPermissions: ->
    @votePermissionsCheckbox().click()

  submitGroupSettingsForm: ->
    element(By.css('.edit-group-form__submit-button')).click()

  groupPage: ->
    element(By.css('.group-page'))

  clickJoinGroupButton: ->
    element(By.css('.join-group-button__join-group')).click()

  askToJoinGroupButton: ->
    element(By.css('.join-group-button__ask-to-join-group'))

  clickAskToJoinGroupButton: ->
     @askToJoinGroupButton().click()

  submitMembershipRequestForm: ->
    element(By.css('.membership-request-form__submit-btn')).click()

  groupMembersPanel: ->
    element(By.css('.group-page-members'))

  groupDescriptionPanel: ->
    element(By.css('.group-page__description'))

  groupThreadsList: ->
    element(By.css('.group-thread-list'))

  subgroupsPanel: ->
    element(By.css('.subgroups-card'))

  clickLeaveGroupButton: ->
    element(By.css('.group-page-actions__leave_group')).click()

  confirmLeaveGroup: ->
    element(By.css('.leave-group-form__submit')).click()

  visitGroupPage: ->
    element(By.css('.groups-item')).click()

  groupsList: ->
    element(By.css('.groups-page__groups'))

  leaveGroupForm: ->
    element(By.css('.leave-group-form'))

  clickAddCoordinatorButton: ->
    element(By.css('.leave-group-form__add-coordinator')).click()
