describe 'Proposals', ->

  threadHelper = require './helpers/thread_helper.coffee'
  proposalsHelper = require './helpers/proposals_helper.coffee'
  emailHelper = require './helpers/email_helper.coffee'

  describe 'starting a proposal', ->

    beforeEach ->
      threadHelper.load()

    it 'successfully starts a new proposal', ->
      proposalsHelper.startProposalBtn().click()
      proposalsHelper.fillInProposalForm({ title: 'New proposal', details: 'Describing the proposal' })
      proposalsHelper.submitProposalForm()
      # expect(threadHelper.flashMessageText()).toContain('Successfully created your proposal')

  describe 'voting on a proposal', ->

    beforeEach ->
      threadHelper.loadWithActiveProposal()

    it 'successfully votes on a proposal', ->
      proposalsHelper.clickAgreeBtn()
      proposalsHelper.setVoteStatement('This is a good idea')
      proposalsHelper.submitVoteForm()
      expect(proposalsHelper.positionsList().getText()).toContain('agreed')
      expect(proposalsHelper.positionsList().getText()).toContain('This is a good idea')

  describe 'updating a vote on a proposal', ->
    beforeEach ->
      threadHelper.loadWithActiveProposalWithVotes()

    it 'successfully updates a previous vote on a proposal', ->
      proposalsHelper.clickChangeBtn()
      proposalsHelper.selectVotePosition('no')
      proposalsHelper.setVoteStatement('This is not a good idea')
      proposalsHelper.submitVoteForm()
      expect(proposalsHelper.positionsList().getText()).toContain('disagreed')
      expect(proposalsHelper.positionsList().getText()).toContain('This is not a good idea')

  describe 'editing a proposal', ->

    beforeEach ->
      threadHelper.loadWithActiveProposal()

    it 'successfully edits a proposal when there are no votes', ->
      proposalsHelper.proposalActionsDropdown().click()
      proposalsHelper.proposalActionsDropdownEdit().click()
      proposalsHelper.fillInProposalForm({ title: 'Edited proposal' })
      proposalsHelper.saveProposalChangesBtn().click()
      expect(proposalsHelper.currentProposalHeading().getText()).toContain('Edited proposal')

  describe 'closing a proposal', ->

    beforeEach ->
      threadHelper.loadWithActiveProposal()

    it 'successfully closes a proposal', ->
      proposalsHelper.proposalActionsDropdown().click()
      proposalsHelper.proposalActionsDropdownClose().click()
      proposalsHelper.closeProposalButton().click()
      expect(proposalsHelper.previousProposalsList().getText()).toContain('lets go hiking')

  describe 'setting a proposal outcome', ->

    it 'successfully creates a proposal outcome', ->
      threadHelper.loadWithClosedProposal()
      proposalsHelper.proposalExpandLink().click()
      proposalsHelper.setProposalOutcomeBtn().click()
      proposalsHelper.fillInProposalOutcomeForm({ body: 'Everyone is happy!' })
      proposalsHelper.submitProposalOutcomeForm()
      expect(proposalsHelper.currentExpandedProposalOutcome().getText()).toContain('Everyone is happy!')

    it 'successfully edits a proposal outcome', ->
      threadHelper.loadWithSetOutcome()
      proposalsHelper.proposalExpandLink().click()
      proposalsHelper.editOutcomeLink().click()
      proposalsHelper.editProposalOutcomeForm({ body: 'Gonna make things happen!' })
      proposalsHelper.submitProposalOutcomeForm()
      expect(proposalsHelper.currentExpandedProposalOutcome().getText()).toContain('Gonna make things happen!')

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
          expect(proposalsHelper.undecidedPanel().getText()).toContain('Emilio')
          expect(proposalsHelper.undecidedPanel().getText()).toContain('Hide undecided members')

        it 'hides all undecided members when undecided panel is open and hide link is clicked', ->
          proposalsHelper.clickHideUndecidedLink()
          expect(proposalsHelper.undecidedPanel().getText()).toContain('Show undecided members')

      describe 'when proposal is closed', ->

        beforeEach ->
          threadHelper.loadWithClosedProposal()

        xit 'shows all undecided members when the show link is clicked', ->
          # invitationsHelper.inviteUser()
          # threadHelper.visitDiscussionPage()
          # proposalsHelper.clickShowUndecidedLink()
          # expect(proposalsHelper.undecidedPanel().getText()).not.toContain('Max')
