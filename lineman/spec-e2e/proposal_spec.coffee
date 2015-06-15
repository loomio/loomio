describe 'Proposals', ->

  threadHelper = require './helpers/thread_helper.coffee'
  proposalsHelper = require './helpers/proposals_helper.coffee'

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
      threadHelper.loadWithActiveProposalWithVote()   

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
