describe 'Managing membership requests', ->

  membershipRequestsHelper = require './helpers/membership_requests_helper.coffee'
  groupsHelper = require './helpers/groups_helper.coffee'
  emailHelper = require './helpers/email_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'

  beforeEach ->
    membershipRequestsHelper.loadWithMembershipRequests()
    membershipRequestsHelper.clickMembershipRequestsLink()

  describe 'approving a membership request', ->

    it 'successfully approves a membership request', ->
      membershipRequestsHelper.clickApproveButton()
      expect(membershipRequestsHelper.previousRequestsPanel()).toContain('Approved by Patrick Swayze')

    it 'adds existing users to group upon approval', ->
      membershipRequestsHelper.clickApproveButton()
      membershipRequestsHelper.clickApproveButton()
      membershipRequestsHelper.clickNavbarGroupLink()
      membershipRequestsHelper.clickGroupName()
      expect(groupsHelper.membersList()).toContain('MVS')

    it 'sends an invitation to non-users upon approval', ->
      membershipRequestsHelper.clickApproveButton()
      membershipRequestsHelper.clickApproveButton()
      emailHelper.openLastEmail()
      expect(emailHelper.lastEmailSubject().getText()).toContain('Membership approved')

    it 'displays the correct flash message', ->
      membershipRequestsHelper.clickApproveButton()
      expect(flashHelper.flashMessage()).toContain('Membership request approved')


  describe 'ignoring a membership request', ->

    it 'successfully ignores a membership request', ->
      membershipRequestsHelper.clickIgnoreButton()
      expect(membershipRequestsHelper.previousRequestsPanel()).toContain('Ignored by Patrick Swayze')

    it 'displays the correct flash message', ->
      membershipRequestsHelper.clickIgnoreButton()
      expect(flashHelper.flashMessage()).toContain('Membership request ignored')

  describe 'when there are no pending membership requests', ->

    it 'tells you there are no pending membership requests', ->
      membershipRequestsHelper.approveAllRequests()
      expect(membershipRequestsHelper.pendingRequestsPanel()).toContain('There are currently no pending membership requests for this group.')
