describe 'Proposals', ->

  DiscussionPage = require './helpers/discussion_page.coffee'
  page = new DiscussionPage

  describe 'voting', ->
    beforeEach ->
      page.loadWithActiveProposal()

    describe 'first vote on a proposal', ->
      beforeEach ->
        page.agreeButton().click()
        page.voteStatementInput().sendKeys('I do agree')
        page.submitPositionButton().click()

      it 'displays your current vote and statement', ->
        expect(page.yourPositionIcon().isPresent()).toBe(true)
        expect(page.yourVoteStatement().getText()).toContain('I do agree')

      it 'appends your vote to the discussion thread', ->
        expect(page.newVoteDiscussionItem().getText()).toContain('I do agree')

    #describe 'cancelling before voting', ->
      #beforeEach ->
        #page.agreeButton().click()
        #page.voteStatementInput().sendKeys('I do agree')
      #it 'closes the vote form'
      #it 'does not have a current vote for you'

  # descirbe 'editing a proposal'

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

      # not too sure why this one does not work
      # it 'displays a flash message', ->
        #expect(page.flashMessageText()).toContain('created your proposal')

      it 'shows the new proposal as the expanded current proposal', ->
        expect(page.expandedProposalTitleText()).toContain('test proposal')

    describe 'invalid due to another proposal already started', ->
      it "does not close the modal", ->
        expect(page.modal().isPresent()).toBe(true)

      # pending
      #it "displays the validation errors", ->
        #expect(element(By.css('.proposal-form .form-errors')).getText()).toContain('Another proposal is already active')
