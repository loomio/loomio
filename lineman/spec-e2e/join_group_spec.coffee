describe 'Joining group', ->

  groupsHelper = require './helpers/groups_helper.coffee'

  describe 'membership granted upon request', ->
    beforeEach ->
      groupsHelper.loadToJoin('request')

    it 'adds you to the group when clicked', ->
      groupsHelper.clickJoinGroupButton()
      expect(groupsHelper.flashSection().getText()).toContain('You are now a member of')
      expect(groupsHelper.membersList().getText()).toContain('JG')

  describe 'membership granted upon approval', ->
    beforeEach ->
      groupsHelper.loadToJoin('approval')

    it 'requests membership when clicked', ->
      groupsHelper.clickAskToJoinGroupButton()
      groupsHelper.submitMembershipRequestForm()
      expect(groupsHelper.flashSection().getText()).toContain('You have requested membership')
      expect(groupsHelper.askToJoinGroupButton().isPresent()).toBeFalsy()
