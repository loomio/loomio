describe 'Managing membership requests', ->

  membershipRequestsHelper = require './helpers/membership_requests_helper.coffee'
  emailHelper = require './helpers/email_helper.coffee'
  page        = require './helpers/page_helper.coffee'

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
      membershipRequestsHelper.clickGroupName()
      page.expectText '.members-card', 'MVS'

    it 'sends an invitation to non-users upon approval', ->
      membershipRequestsHelper.clickApproveButton()
      membershipRequestsHelper.clickApproveButton()
      emailHelper.openLastEmail()
      expect(emailHelper.lastEmailSubject().getText()).toContain('Your request to join Dirty Dancing Shoes has been approved')

    it 'displays the correct flash message', ->
      membershipRequestsHelper.clickApproveButton()
      browser.driver.sleep(300)
      page.expectFlash('Membership request approved')

  describe 'ignoring a membership request', ->

    it 'successfully ignores a membership request', ->
      membershipRequestsHelper.clickIgnoreButton()
      expect(membershipRequestsHelper.previousRequestsPanel()).toContain('Ignored by Patrick Swayze')

    it 'displays the correct flash message', ->
      membershipRequestsHelper.clickIgnoreButton()
      page.expectFlash('Membership request ignored')

  describe 'when there are no pending membership requests', ->

    it 'tells you there are no pending membership requests', ->
      membershipRequestsHelper.approveAllRequests()
      expect(membershipRequestsHelper.pendingRequestsPanel()).toContain('There are currently no pending membership requests for this group.')
