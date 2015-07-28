describe 'Managing membership requests', ->

  membershipRequestsHelper = require './helpers/membership_requests_helper.coffee'
  groupsHelper = require './helpers/groups_helper.coffee'
  emailHelper = require './helpers/email_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'

  beforeEach ->
    membershipRequestsHelper.loadWithMembershipRequests()
    membershipRequestsHelper.visitMembershipRequestsPage()

  describe 'approving a membership request', ->

    it 'successfully approves a membership request', ->
      membershipRequestsHelper.clickApproveButton()
      expect(membershipRequestsHelper.previousRequestsPanel().getText()).toContain('Approved by Patrick Swayze')

    it 'adds existing users to group upon approval', ->
      membershipRequestsHelper.clickApproveButton()
      membershipRequestsHelper.clickApproveButton()
      membershipRequestsHelper.visitGroupPage()
      expect(groupsHelper.membersList().getText()).toContain('MVS')

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
      expect(membershipRequestsHelper.previousRequestsPanel().getText()).toContain('Ignored by Patrick Swayze')

    it 'displays the correct flash message', ->
      membershipRequestsHelper.clickIgnoreButton()
      expect(flashHelper.flashMessage()).toContain('Membership request ignored')
