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
      threadHelper.loadWithActiveProposalWithVotes()

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
      proposalsHelper.fillInProposalForm({ title: 'Edited proposal' })
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
      threadHelper.loadWithClosedProposal()
      proposalsHelper.clickProposalExpandLink()
      expect(proposalsHelper.currentExpandedProposal()).toContain('lets go hiking')
      expect(proposalsHelper.currentExpandedProposal()).toContain('Closed a few seconds ago')

  describe 'setting a proposal outcome', ->
    beforeEach ->
      # resize the window for the freak case of navbar covering the button and
      # the driver not finding the element
      browser.driver.manage().window().setSize(1280, 1024);

    it 'creates a proposal outcome', ->
      threadHelper.loadWithClosedProposal()
      proposalsHelper.clickProposalExpandLink()
      proposalsHelper.setProposalOutcomeBtn().click()
      proposalsHelper.fillInProposalOutcome('Everyone is happy!')
      proposalsHelper.submitProposalOutcomeForm()
      expect(flashHelper.flashMessage()).toContain('Outcome published')
      expect(proposalsHelper.currentExpandedProposalOutcome()).toContain('Everyone is happy!')

    it 'edits a proposal outcome', ->
      threadHelper.loadWithSetOutcome()
      proposalsHelper.clickProposalExpandLink()
      proposalsHelper.editOutcomeLink().click()
      proposalsHelper.fillInProposalOutcome('Gonna make things happen!')
      proposalsHelper.submitProposalOutcomeForm()
      expect(flashHelper.flashMessage()).toContain('Outcome updated')
      expect(proposalsHelper.currentExpandedProposalOutcome()).toContain('Gonna make things happen!')

  describe 'voting by email', ->

    beforeEach ->
      threadHelper.loadWithActiveProposal()

    xit 'opens the voting modal when email link is clicked', ->
      emailHelper.openLastEmail()
      emailHelper.clickAgreeLink()
      expect(proposalsHelper.voteFormPositionSelect().getAttribute('value')).toContain('yes')

  describe 'undecided members', ->

      describe 'when proposal is open', ->

        beforeEach ->
          threadHelper.loadWithActiveProposalWithVotes()
          proposalsHelper.clickShowUndecidedLink()

        it 'shows all undecided members when the show link is clicked', ->
          expect(proposalsHelper.undecidedPanel()).toContain('Emilio')
          expect(proposalsHelper.undecidedPanel()).toContain('Hide undecided members')

        it 'hides all undecided members when undecided panel is open and hide link is clicked', ->
          proposalsHelper.clickHideUndecidedLink()
          expect(proposalsHelper.undecidedPanel()).toContain('Show undecided members')

      describe 'when proposal is closed', ->

        beforeEach ->
          threadHelper.loadWithClosedProposal()

        xit 'shows all undecided members when the show link is clicked', ->
          # invitationsHelper.inviteUser()
          # threadHelper.visitDiscussionPage()
          # proposalsHelper.clickShowUndecidedLink()
          # expect(proposalsHelper.undecidedPanel().getText()).not.toContain('Max')

  describe 'visibility', ->

    it 'hides member actions from visitors', ->
      threadHelper.loadWithPublicContent()
      expect(proposalsHelper.positionButtons().isPresent()).toBe(false)
