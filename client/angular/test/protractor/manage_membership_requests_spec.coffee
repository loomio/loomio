describe 'Managing membership requests', ->

  emailHelper = require './helpers/email_helper.coffee'
  page        = require './helpers/page_helper.coffee'

  beforeEach ->
    page.loadPath 'setup_membership_requests'
    page.click '.membership-requests-card__link'

  describe 'approving a membership request', ->
    it 'successfully approves a membership request', ->
      page.click '.membership-requests-page__approve'
      page.expectText '.membership-requests-page__previous-requests', 'Approved by Patrick Swayze'

    it 'adds existing users to group upon approval', ->
      page.clickFirst '.membership-requests-page__approve'
      page.clickFirst '.membership-requests-page__approve'
      page.clickFirst '.sidebar__list-item-button--group'
      page.expectText '.members-card', 'MVS'

    it 'sends an invitation to non-users upon approval', ->
      page.clickFirst '.membership-requests-page__approve'
      page.clickFirst '.membership-requests-page__approve'
      page.loadPath 'last_email'
      expect(emailHelper.lastEmailSubject().getText()).toContain('Your request to join Dirty Dancing Shoes has been approved')

    it 'displays the correct flash message', ->
      page.clickFirst '.membership-requests-page__approve'
      browser.driver.sleep(300)
      page.expectFlash 'Membership request approved'

  describe 'ignoring a membership request', ->
    it 'successfully ignores a membership request', ->
      page.clickFirst '.membership-requests-page__ignore'
      page.expectText '.membership-requests-page__previous-requests', 'Ignored by Patrick Swayze'

    it 'displays the correct flash message', ->
      page.clickFirst '.membership-requests-page__ignore'
      page.expectFlash('Membership request ignored')

  describe 'when there are no pending membership requests', ->
    it 'tells you there are no pending membership requests', ->
      page.clickFirst '.membership-requests-page__approve'
      page.clickFirst '.membership-requests-page__approve'
      page.clickFirst '.membership-requests-page__approve'
      page.clickFirst '.membership-requests-page__approve'
      page.expectText '.membership-requests-page__pending-requests', 'There are currently no pending membership requests for this group.'
