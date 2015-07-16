describe 'Group Page', ->

  groupsHelper = require './helpers/groups_helper.coffee'
  membershipsHelper = require './helpers/memberships_helper.coffee'

  describe 'starting a discussion', ->
    beforeEach ->
      groupsHelper.load()

    it 'successfully starts a discussion', ->
      groupsHelper.clickStartThreadButton()
      groupsHelper.fillInDiscussionTitle('Nobody puts baby in a corner')
      groupsHelper.fillInDiscussionDescription("I've had the time of my life")
      groupsHelper.submitDiscussionForm()
      expect(groupsHelper.discussionTitle().getText()).toContain('Nobody puts baby in a corner')
      expect(groupsHelper.discussionTitle().getText()).toContain("I've had the time of my life")

  describe 'editing group settings', ->
    beforeEach ->
      groupsHelper.load()

    it 'successfully edits group name', ->
      groupsHelper.visitEditGroupPage()
      groupsHelper.editGroupName('Dancing Dirty Shoes')
      groupsHelper.submitEditGroupForm()
      expect(groupsHelper.flashSection().getText()).toContain('Group updated')
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
      expect(groupsHelper.flashSection().getText()).toContain('Group updated')
      expect(groupsHelper.groupPageDescriptionText().getText()).toContain("Describin' the group")

    it 'successfully edits group privacy', ->
      groupsHelper.visitEditGroupPage()
      groupsHelper.changeGroupVisibilitySettings()
      groupsHelper.submitEditGroupForm()
      expect(groupsHelper.groupPage().getText()).toContain('This group is only visible to members')

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
      expect(groupsHelper.flashSection().getText()).toContain('You have left this group')
      groupsHelper.visitGroupPage()
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
      expect(membershipsHelper.membershipsPageHeader().isDisplayed()).toBeTruthy
