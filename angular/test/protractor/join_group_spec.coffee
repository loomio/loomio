describe 'Joining group', ->

  groupsHelper = require './helpers/groups_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'
  page = require './helpers/page_helper.coffee'

  describe 'display', ->

    beforeEach ->
      groupsHelper.loadPath('setup_closed_group_to_join')

    it 'hides private content', ->
      expect(groupsHelper.memberOptionsDropdown().isPresent()).toBeFalsy()
      expect(groupsHelper.startThreadButton().isPresent()).toBeFalsy()
      expect(groupsHelper.groupMembersPanel().isPresent()).toBeFalsy()

    it 'displays public content', ->
      expect(groupsHelper.groupDescriptionPanel().getText()).toContain('An FBI agent goes undercover')
      expect(groupsHelper.groupThreadsList().getText()).toContain("The name's Johnny Utah!")
      expect(groupsHelper.subgroupsPanel().getText()).toContain('Johnny Utah')

  describe 'membership granted upon request', ->
    beforeEach ->
      groupsHelper.loadPath('setup_public_group_to_join_upon_request')

    it 'adds you to the group when button is clicked', ->
      groupsHelper.clickJoinGroupButton()
      expect(flashHelper.flashMessage()).toContain('You are now a member of')
      expect(groupsHelper.membersList().getText()).toContain('JG')

  describe 'membership granted upon approval', ->
    beforeEach ->
      groupsHelper.loadPath('setup_closed_group_to_join')

    it 'requests membership when button is clicked', ->
      groupsHelper.clickAskToJoinGroupButton()
      groupsHelper.submitMembershipRequestForm()
      expect(flashHelper.flashMessage()).toContain('You have requested membership')
