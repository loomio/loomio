describe 'Managing memberships', ->

  membershipsHelper = require './helpers/memberships_helper.coffee'
  groupsHelper = require './helpers/groups_helper.coffee'
  page = require './helpers/page_helper.coffee'

  beforeEach ->
    groupsHelper.load()
    membershipsHelper.visitMembershipsPage()

  describe 'removing a group member', ->

    it 'successfully removes a group member', ->
      membershipsHelper.fillInSearchInput('Jennifer')
      membershipsHelper.clickRemoveLink()
      membershipsHelper.confirmRemoveAction()
      expect(membershipsHelper.currentMembershipRow().isPresent()).toBe(false)
      membershipsHelper.clearSearchInput()
      page.expectFlash 'Removed Jennifer Grey'
      expect(membershipsHelper.membershipsTable()).not.toContain('Jennifer Grey')

  describe 'promoting a member to coordinator', ->

    it 'successfully assigns coordinator privileges', ->
      membershipsHelper.fillInSearchInput('Jennifer')
      membershipsHelper.checkCoordinatorCheckbox()
      membershipsHelper.clearSearchInput()
      page.expectFlash 'Jennifer Grey is now a coordinator'
      expect(membershipsHelper.currentCoordinatorsCount()).toEqual(2)

  describe 'adding someone as a non-coordinator', ->
    it 'allows non-coordinators to add members if the group settings allow', ->
      page.loadPath('setup_group_as_member')
      page.click '.members-card__manage-members'
      page.expectElement '.memberships-panel__membership'
      page.expectElement '.memberships-page__invite'

  describe 'removing coordinator privileges', ->

    it 'can remove coordinator privileges when there is more than one coordinator', ->
      membershipsHelper.makeJenniferCoordinator()
      membershipsHelper.clearSearchInput()
      expect(membershipsHelper.currentCoordinatorsCount()).toEqual(2)
      membershipsHelper.fillInSearchInput('Patrick')
      membershipsHelper.checkCoordinatorCheckbox()
      membershipsHelper.confirmRemoval()
      page.expectFlash 'Patrick Swayze is no longer a coordinator'
      membershipsHelper.clearSearchInput()
      expect(membershipsHelper.currentCoordinatorsCount()).toEqual(1)

    it 'cannot remove privileges for last coordinator', ->
      expect(membershipsHelper.currentCoordinatorsCount()).toEqual(1)
      membershipsHelper.fillInSearchInput('Patrick')
      expect(membershipsHelper.coordinatorCheckbox().isEnabled()).toBe(false)
