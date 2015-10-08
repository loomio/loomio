describe 'Group Page', ->

  groupsHelper = require './helpers/groups_helper.coffee'
  membershipsHelper = require './helpers/memberships_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'
  discussionForm = require './helpers/discussion_form_helper.coffee'
  threadPage = require './helpers/thread_helper.coffee'

  describe 'starting a discussion', ->
    beforeEach ->
      groupsHelper.load()

    it 'successfully starts a discussion', ->
      groupsHelper.clickStartThreadButton()
      discussionForm.fillInTitle('Nobody puts baby in a corner')
      discussionForm.fillInDescription("I've had the time of my life")
      discussionForm.clickSubmit()
      expect(threadPage.discussionTitle().getText()).toContain('Nobody puts baby in a corner')
      expect(threadPage.discussionTitle().getText()).toContain("I've had the time of my life")

    it 'prevents losing form content if you accidentally cancel', ->
      groupsHelper.clickStartThreadButton()
      discussionForm.fillInTitle('Nobody puts baby in a corner')
      discussionForm.fillInDescription("I've had the time of my life")
      discussionForm.clickCancel()
      alert = browser.switchTo().alert()
      alert.dismiss()
      discussionForm.clickSubmit()
      expect(threadPage.discussionTitle().getText()).toContain('Nobody puts baby in a corner')
      expect(threadPage.discussionTitle().getText()).toContain("I've had the time of my life")

  describe 'starting a subgroup', ->
    beforeEach ->
      groupsHelper.load()

    it 'successfully starts a subgroup', ->
      groupsHelper.clickStartSubgroupLink()
      groupsHelper.fillInSubgroupName('The Breakfast Club')
      groupsHelper.submitSubgroupForm()
      #expect(flashHelper.flashMessage()).toContain('Subgroup created')
      #expect(groupsHelper.groupName()).toContain('Dirty Dancing Shoes')
      expect(groupsHelper.groupName()).toContain('The Breakfast Club')

  describe 'editing group settings', ->
    beforeEach ->
      groupsHelper.load()

    it 'successfully edits group name', ->
      groupsHelper.visitEditGroupPage()
      groupsHelper.editGroupName('Dancing Dirty Shoes')
      groupsHelper.submitEditGroupForm()
      expect(flashHelper.flashMessage()).toContain('Group updated')
      expect(groupsHelper.groupPageHeader().getText()).toContain('Dancing Dirty Shoes')

    it 'throws a validation error when name is blank', ->
      groupsHelper.visitEditGroupPage()
      groupsHelper.clearGroupNameInput()
      groupsHelper.submitEditGroupForm()
      expect(groupsHelper.editGroupFormValidationErrors().isDisplayed()).toBeTruthy()
      expect(groupsHelper.editGroupFormValidationErrors().getText()).toContain("can't be blank")

     it 'successfully edits group description', ->
      groupsHelper.visitEditGroupPage()
      groupsHelper.editGroupDescription("Describin' the group")
      groupsHelper.submitEditGroupForm()
      expect(flashHelper.flashMessage()).toContain('Group updated')
      expect(groupsHelper.groupPageDescriptionText().getText()).toContain("Describin' the group")

    it 'successfully edits group privacy', ->
      groupsHelper.visitEditGroupPage()
      groupsHelper.changeGroupVisibilitySettings()
      groupsHelper.submitEditGroupForm()
      expect(groupsHelper.groupPage()).toContain('This group is only visible to members')

    it 'successfully edits group permissions', ->
      groupsHelper.visitEditGroupPage()
      groupsHelper.changeVotingPermissions()
      groupsHelper.submitEditGroupForm()
      groupsHelper.visitEditGroupPage()
      expect(groupsHelper.votePermissionsCheckbox().isSelected()).not.toBeTruthy()

  describe 'leaving a group', ->

    it 'allows group members to leave the group', ->
      groupsHelper.loadWithMultipleCoordinators()
      groupsHelper.openMemberOptionsDropdown()
      groupsHelper.clickLeaveGroupButton()
      groupsHelper.confirmLeaveGroup()
      expect(flashHelper.flashMessage()).toContain('You have left this group')
      groupsHelper.visitGroupsPage()
      expect(groupsHelper.groupsList().getText()).not.toContain('Dirty Dancing Shoes')

    it 'prevents last coordinator from leaving the group', ->
      groupsHelper.load()
      groupsHelper.openMemberOptionsDropdown()
      groupsHelper.clickLeaveGroupButton()
      expect(groupsHelper.leaveGroupForm().getText()).toContain('You cannot leave this group')

    it 'prompts last coordinator to add another coordinator in order to leave group', ->
      groupsHelper.load()
      groupsHelper.openMemberOptionsDropdown()
      groupsHelper.clickLeaveGroupButton()
      groupsHelper.clickAddCoordinatorButton()
      expect(membershipsHelper.membershipsPageHeader().isDisplayed()).toBeTruthy()

  describe 'archiving a group', ->

    it 'allows a coordinator to archive a group', ->
      groupsHelper.load()
      groupsHelper.openMemberOptionsDropdown()
      groupsHelper.clickArchiveGroupButton()
      groupsHelper.confirmArchiveGroup()
      expect(flashHelper.flashMessage()).toContain('This group has been deactivated')
      groupsHelper.visitGroupsPage()
      expect(groupsHelper.groupsList().getText()).not.toContain('Dirty Dancing Shoes')
