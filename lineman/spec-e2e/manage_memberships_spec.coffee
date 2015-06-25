describe 'Managing memberships', ->

  membershipsHelper = require './helpers/memberships_helper.coffee'
  groupsHelper = require './helpers/groups_helper.coffee'

  beforeEach ->
    groupsHelper.load()

  describe 'removing a group member', ->

    it 'successfully removes a group member', ->
      membershipsHelper.visitMembershipsPage()
      membershipsHelper.fillInSearchInput('Jennifer')
      membershipsHelper.clickRemoveLink()
      membershipsHelper.confirmRemoveAction()
      expect(membershipsHelper.currentMembershipRow().isPresent()).toBe(false)
      membershipsHelper.clearSearchInput()
      expect(membershipsHelper.membershipsTable().getText()).not.toContain('Jennifer Grey')

  describe 'promoting a member to coordinator', ->

    it 'successfully assigns coordinator privileges', ->
      membershipsHelper.visitMembershipsPage()
      membershipsHelper.fillInSearchInput('Jennifer')
      membershipsHelper.checkCoordinatorCheckbox()
      membershipsHelper.clearSearchInput()
      expect(membershipsHelper.currentCoordinatorsCount()).toEqual(2)

  describe 'removing a coordinator', ->

    it 'cannot remove the last coordinator', ->
      membershipsHelper.visitMembershipsPage()
      expect(membershipsHelper.currentCoordinatorsCount()).toEqual(1)
      membershipsHelper.fillInSearchInput('Patrick')
      expect(membershipsHelper.coordinatorCheckbox().isEnabled()).toBe(false)
