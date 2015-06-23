describe 'Managing memberships', ->

  membershipsHelper = require './helpers/memberships_helper.coffee'
  groupsHelper = require './helpers/groups_helper.coffee'

  beforeEach ->
    groupsHelper.load()

  describe 'removing a group member', ->

    it 'successfully removes a group member', ->
      membershipsHelper.visitMembershipsPage()
      expect(membershipsHelper.currentMembershipsCount()).toEqual(2)
      membershipsHelper.clickRemoveLink()
      expect(membershipsHelper.currentMembershipsCount()).toEqual(1)

  describe 'promoting a member to coordinator', ->

    it 'successfully assigns coordinator privileges', ->
      membershipsHelper.visitMembershipsPage()
      membershipsHelper.checkCoordinatorCheckbox()
      expect(membershipsHelper.currentCoordinatorsCount()).toEqual(2)

  describe 'removing a coordinator', ->

    it 'cannot remove the last coordinator', ->
      membershipsHelper.visitMembershipsPage()
      expect(membershipsHelper.currentCoordinatorsCount()).toEqual(1)
      expect(membershipsHelper.disabledCoordinatorCheckbox().isEnabled()).toBe(false)


