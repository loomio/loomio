describe 'Proposals', ->

  DiscussionPage = require './helpers/discussion_page.coffee'
  page = new DiscussionPage

  describe 'voting', ->
    beforeEach ->
      page.loadWithActiveProposal()

    describe 'vote on a proposal', ->
      beforeEach ->
        page.agreeButton().click()
        page.voteStatementInput().sendKeys('I do agree')
        page.submitPositionButton().click()

      it 'displays your current vote and statement', ->
        expect(page.yourPositionIcon().isPresent()).toBe(true)
        expect(page.yourVoteStatement().getText()).toContain('I do agree')

      it 'appends your vote to the discussion thread', ->
        expect(page.newVoteDiscussionItem().getText()).toContain('I do agree')

      it 'lets you change position', ->
        page.editPositionButton().click()
        page.abstainButton().click()
        page.voteStatementInput().clear().sendKeys('now im iffy')
        page.submitPositionButton().click()
        expect(page.yourVoteStatement().getText()).toContain('now im iffy')


  describe 'starting a proposal', ->
    beforeEach ->
      page.load()
      page.startProposalLink().click()

    describe 'then cancelling', ->
      beforeEach ->
        page.cancelProposalBtn().click()

      it 'closes the modal', ->
        expect(page.modal().isPresent()).toBe(false)

    describe 'successfully', ->
      beforeEach ->
        page.fillInProposalForm('test proposal', 'the details are in the details')
        page.submitProposalForm()

      it 'closes the modal', ->
        expect(page.modal().isPresent()).toBe(false)

      it 'shows the new proposal as the expanded current proposal', ->
        expect(page.expandedProposalTitleText()).toContain('test proposal')

  describe 'editing propsal', ->
    beforeEach ->
      page.loadWithActiveProposal()

    it 'lets you edit proposal when there are no votes', ->
      page.proposalActionsDropdown().click()
      page.proposalActionsDropdownEdit().click()
      page.fillInProposalForm('updated title', 'the details are not the same')
      page.submitProposalForm()
      expect(page.modal().isPresent()).toBe(false)
      expect(page.expandedProposalTitleText()).toContain('updated title')

  describe 'closing propsal', ->
    beforeEach ->
      page.loadWithActiveProposal()

    it 'closes the proposal', ->
      page.proposalActionsDropdown().click()
      page.proposalActionsDropdownClose().click()
      page.closeProposalButton().click()
      expect(page.modal().isPresent()).toBe(false)
      page.firstCollpasedProposal().click()
      expect(page.proposalClosedBadge().isPresent()).toBe(true)

  describe 'changing close time', ->
    beforeEach ->
      page.loadWithActiveProposal()
      page.agreeWithProposal('yes why not')

    it 'lets admin change close time', ->
      page.proposalActionsDropdown().click()
      page.proposalActionsDropdownChangeCloseTime().click()
      # something about updating the time

