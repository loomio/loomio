describe 'Proposals', ->

  page = require './helpers/page_helper.coffee'
  threadHelper = require './helpers/thread_helper.coffee'
  proposalsHelper = require './helpers/proposals_helper.coffee'
  emailHelper = require './helpers/email_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'

  describe 'starting a proposal', ->

    beforeEach ->
      threadHelper.load()

    it 'successfully starts a new proposal', ->
      proposalsHelper.startProposalBtn().click()
      proposalsHelper.fillInProposalForm({ title: 'New proposal', details: 'Describing the proposal' })
      proposalsHelper.submitProposalForm()
      expect(flashHelper.flashMessage()).toContain('Proposal started')

  describe 'voting on a proposal', ->

    beforeEach ->
      threadHelper.loadWithActiveProposal()

    it 'successfully votes on a proposal', ->
      proposalsHelper.clickAgreeBtn()
      proposalsHelper.setVoteStatement('This is a good idea')
      proposalsHelper.submitVoteForm()
      page.expectText('.proposal-positions-panel__list', 'Patrick Swayze')
      page.expectText('.proposal-positions-panel__list', 'agreed')
      page.expectText('.proposal-positions-panel__list', 'This is a good idea')

  describe 'updating a vote on a proposal', ->
    beforeEach ->
      page.loadPath 'setup_proposal_with_votes'

    it 'successfully updates a previous vote on a proposal', ->
      proposalsHelper.clickChangeBtn()
      proposalsHelper.selectVotePosition('no')
      proposalsHelper.setVoteStatement('This is not a good idea')
      proposalsHelper.submitVoteForm()
      expect(proposalsHelper.positionsList()).toContain('disagreed')
      expect(proposalsHelper.positionsList()).toContain('This is not a good idea')

  describe 'editing a proposal', ->

    beforeEach ->
      threadHelper.loadWithActiveProposal()

    it 'successfully edits a proposal when there are no votes', ->
      proposalsHelper.clickProposalActionsDropdown()
      proposalsHelper.clickProposalActionsDropdownEdit()
      page.fillIn('.proposal-form__title-field', 'Edited proposal')
      proposalsHelper.clickSaveProposalChangesButton()
      expect(proposalsHelper.currentProposalHeading()).toContain('Edited proposal')

  describe 'closing a proposal', ->

    beforeEach ->
      threadHelper.loadWithActiveProposal()

    it 'successfully closes a proposal', ->
      proposalsHelper.clickProposalActionsDropdown()
      proposalsHelper.clickProposalActionsDropdownClose()
      proposalsHelper.clickCloseProposalButton()
      expect(flashHelper.flashMessage()).toContain('Proposal closed')
      expect(proposalsHelper.previousProposalsList()).toContain('lets go hiking')
      expect(proposalsHelper.previousProposalsList()).toContain('Closed')
      expect(proposalsHelper.positionButtons().isPresent()).toBe(false)

    it 'displays the time at which the proposal closed', ->
      page.loadPath 'setup_closed_proposal'
      page.expectText '.proposal-expanded', 'lets go hiking'
      page.expectText '.proposal-expanded', 'Closed a few seconds ago'

  describe 'setting a proposal outcome', ->
    beforeEach ->
      # resize the window for the freak case of navbar covering the button and
      # the driver not finding the element
      browser.driver.manage().window().setSize(1280, 1024);

    it 'creates a proposal outcome', ->
      page.loadPath 'setup_closed_proposal'
      page.click '.proposal-outcome-panel__set-outcome-btn'
      page.fillIn '.proposal-form__outcome-field', 'Everyone is happy!'
      page.click '.proposal-outcome-form__publish-outcome-btn'
      page.expectFlash 'Outcome published'
      page.expectText '.proposal-outcome-panel__outcome', 'Everyone is happy!'

    it 'edits a proposal outcome', ->
      page.loadPath 'setup_closed_proposal_with_outcome'
      page.click '.proposal-outcome-panel__edit-outcome-link'
      page.fillIn '.proposal-form__outcome-field', 'Gonna make things happen!'
      page.click '.proposal-outcome-form__publish-outcome-btn'
      page.expectFlash 'Outcome updated'
      page.expectText '.proposal-outcome-panel__outcome', 'Gonna make things happen!'

  describe 'redirecting to a proposal', ->
    it 'succeeds when a visitor logs in', ->
      page.loadPath 'view_proposal_as_visitor'
      page.fillIn '#user-email', 'patrick_swayze@example.com'
      page.fillIn '#user-password', 'gh0stmovie'
      page.click '.sign-in-form__submit-button'
      page.waitForReload()
      page.expectText '.proposal-expanded', 'lets go hiking'

  describe 'voting by email', ->

    beforeEach ->
      threadHelper.loadWithActiveProposal()

  describe 'undecided members', ->

    describe 'when proposal is open', ->
      beforeEach ->
        page.loadPath 'setup_proposal_with_votes'

      it 'shows all undecided members when the show link is clicked', ->
        page.click '.undecided-panel__show'
        page.expectText '.undecided-panel', 'Jennifer Grey'
        page.expectText '.undecided-panel', 'Hide undecided members'

      it 'hides all undecided members when hide link is clicked', ->
        page.click '.undecided-panel__show'
        page.click '.undecided-panel__hide-undecided'
        page.expectText '.undecided-panel', 'Show'

      it 'allows you to remind undecided members', ->
        page.click '.undecided-panel__remind'
        # workaround for weird webdriver quirk which results in getText() always being empty for <input> elements
        expect(threadHelper.commentForm().getAttribute('value')).toEqual('@jennifergrey')

    describe 'when proposal is closed', ->
      beforeEach ->
        page.loadPath 'setup_closed_proposal'

      it 'expands the most recent closed proposal', ->
        page.expectText '.proposal-expanded__proposal-name', 'lets go hiking to the moon'

  describe 'visibility', ->

    it 'hides member actions from visitors', ->
      threadHelper.loadWithPublicContent()
      expect(proposalsHelper.positionButtons().isPresent()).toBe(false)
