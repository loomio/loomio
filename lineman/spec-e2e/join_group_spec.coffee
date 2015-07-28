describe 'Joining group', ->

  groupsHelper = require './helpers/groups_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'

  describe 'display', ->

    beforeEach ->
      groupsHelper.loadToJoin('request')

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
      groupsHelper.loadToJoin('request')

    it 'adds you to the group when button is clicked', ->
      groupsHelper.clickJoinGroupButton()
      expect(flashHelper.flashMessage()).toContain('You are now a member of')
      expect(groupsHelper.membersList().getText()).toContain('JG')

  describe 'membership granted upon approval', ->
    beforeEach ->
      groupsHelper.loadToJoin('approval')

    it 'requests membership when button is clicked', ->
      groupsHelper.clickAskToJoinGroupButton()
      groupsHelper.submitMembershipRequestForm()
      expect(flashHelper.flashMessage()).toContain('You have requested membership')
      expect(groupsHelper.askToJoinGroupButton().isPresent()).toBeFalsy()
