module.exports = new class GroupsHelper
  load: ->
    browser.get('http://localhost:8000/development/setup_group')

  loadToJoin: (value) ->
    browser.get("http://localhost:8000/development/setup_group_to_join?membership_granted_upon=#{value}")

  loadWithMultipleCoordinators: ->
    browser.get('http://localhost:8000/development/setup_group_with_multiple_coordinators')

  membersList: ->
    element(By.css('.members-card')).getText()

  startThreadButton: ->
    element(By.css('.discussions-card__new-thread-button'))

  clickStartThreadButton: ->
    @startThreadButton().click()

  memberOptionsDropdown: ->
    element(By.css('.group-page-actions button'))

  openMemberOptionsDropdown: ->
    @memberOptionsDropdown().click()

  clickEditGroupOption: ->
    element(By.css('.group-page-actions__edit-group-link')).click()

  changeGroupVisibilitySettings: ->
    element(By.css('.edit-group-form__visible-to option[value=members]')).click()

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
    element(By.css('.edit-group-form__members-can-vote'))

  changeVotingPermissions: ->
    @votePermissionsCheckbox().click()

  groupNameInput: ->
    element(By.css('.edit-group-form__name'))

  editGroupName: (name) ->
    @groupNameInput().clear().sendKeys(name)

  clearGroupNameInput: ->
    @groupNameInput().clear()

  editGroupFormValidationErrors: ->
    element(By.css('.lmo-validation-error'))

  editGroupDescription: (description) ->
    element(By.css('.edit-group-form__description')).sendKeys(description)

  groupPageDescriptionText: ->
    element(By.css('.group-page__description-text'))

  submitEditGroupForm: ->
    element(By.css('.edit-group-form__submit-button')).click()

  groupPage: ->
    element(By.css('.group-page'))

  groupPageHeader: ->
    element(By.css('.group-page__name h1'))

  clickJoinGroupButton: ->
    element(By.css('.join-group-button__join-group')).click()

  askToJoinGroupButton: ->
    element(By.css('.join-group-button__ask-to-join-group'))

  clickAskToJoinGroupButton: ->
     @askToJoinGroupButton().click()

  submitMembershipRequestForm: ->
    element(By.css('.membership-request-form__submit-btn')).click()

  groupMembersPanel: ->
    element(By.css('.members-card'))

  groupDescriptionPanel: ->
    element(By.css('.group-page__description'))

  groupThreadsList: ->
    element(By.css('.discussions-card'))

  subgroupsPanel: ->
    element(By.css('.subgroups-card'))

  clickLeaveGroupButton: ->
    element(By.css('.group-page-actions__leave-group')).click()

  clickArchiveGroupButton: ->
    element(By.css('.group-page-actions__archive-group')).click()

  confirmLeaveGroup: ->
    element(By.css('.leave-group-form__submit')).click()

  confirmArchiveGroup: ->
    element(By.css('.archive-group-form__submit')).click()

  visitGroupPage: ->
    element(By.css('.groups-item')).click()

  groupsList: ->
    element(By.css('.groups-page__groups'))

  leaveGroupForm: ->
    element(By.css('.leave-group-form'))

  clickAddCoordinatorButton: ->
    element(By.css('.leave-group-form__add-coordinator')).click()

  clickStartSubgroupLink: ->
    browser.sleep(4000) # this has been a tempremantal test, ugh
    element(By.css('.subgroups-card__add-subgroup-link')).click()

  fillInSubgroupName: (name) ->
    element(By.css('.start-group-form__name')).sendKeys(name)

  submitSubgroupForm: ->
    element(By.css('.start-group-form__submit')).click()

  groupName: ->
    element(By.css('.group-page__name')).getText()
