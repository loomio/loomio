module.exports = new class GroupsHelper
  load: (timeout) ->
    browser.get('dev/setup_group', timeout)

  loadPath: (path, timeout) ->
    browser.get('dev/'+path, timeout)

  loadNew: ->
    browser.get('dev/setup_new_group')

  loadToJoin: (value) ->
    browser.get("dev/setup_group_to_join?membership_granted_upon=#{value}")

  loadWithMultipleCoordinators: ->
    browser.get('dev/setup_group_with_multiple_coordinators')

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

  # changeGroupPermissionsOptions: ->
  #   element(By.css('.group-form__group-members-can-add-members')).click()
  #   element(By.css('.group-form__group-members-can-create-subgroups')).click()
  #   element(By.css('.group-form__group-members-can-start-discussions')).click()
  #   element(By.css('.group-form__group-members-can-edit-discussions')).click()
  #   element(By.css('.group-form__group-members-can-edit-comments')).click()
  #   element(By.css('.group-form__group-members-can-raise-motions')).click()

  openGroupSettings: ->
    @openMemberOptionsDropdown()
    @clickEditGroupOption()

  votePermissionsCheckbox: ->
    element(By.css('.group-form__members-can-vote'))

  expandAdvancedSettings: ->
    element(By.css('.group-form__advanced-link')).click()

  changeVotingPermissions: ->
    @votePermissionsCheckbox().click()

  groupNameInput: ->
    element(By.css('.group-form__name input'))

  editGroupName: (name) ->
    @groupNameInput().clear().sendKeys(name)

  clearGroupNameInput: ->
    @groupNameInput().clear()

  submitGroupForm: ->
    element(By.css('.group-form__submit-button')).click()

  groupPage: ->
    element(By.css('.group-page')).getText()

  groupPageHeader: ->
    element(By.css('.group-theme__name h1'))

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
    element(By.css('.description-card'))

  groupThreadsList: ->
    element(By.css('.discussions-card'))

  subgroupsPanel: ->
    element(By.css('.subgroups-card'))

  clickLeaveGroupButton: ->
    element(By.css('.group-page-actions__leave-group')).click()

  clickArchiveGroupButton: ->
    element(By.css('.group-page-actions__archive-group')).click()

  confirmLeaveGroup: ->
    element(By.css('.leave-group-form__submit-button')).click()

  confirmArchiveGroup: ->
    element(By.css('.archive-group-form__submit-button')).click()

  visitGroupsPage: ->
    element(By.css('.groups-item')).click()

  groupsList: ->
    element(By.css('.groups-page__groups'))

  leaveGroupForm: ->
    element(By.css('.leave-group-form'))

  clickAddCoordinatorButton: ->
    element(By.css('.leave-group-form__add-coordinator')).click()

  clickStartSubgroupLink: ->
    element(By.css('.subgroups-card__add-subgroup-link')).click()

  groupName: ->
    element(By.css('.group-theme__name')).getText()

  visitFirstGroup: ->
    element.all(By.css('.groups-page__parent-group-name a')).first().click()

  clickAddSubgroupLink: ->
    element(By.css('.group-page-actions__add-subgroup-link')).click()

  clickFirstThread: ->
    element(By.css('.thread-preview__link')).click()

  visitMembersPage: ->
    element(By.css('.members-card__manage-members')).click()

  returnToGroupPage: ->
    element(By.css('.lmo-h1')).click()
