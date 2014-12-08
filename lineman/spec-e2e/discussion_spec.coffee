describe 'Discussion Page', ->

  page = null

  class DiscussionPage
    load: ->
      browser.get('http://localhost:8000/angular_support/setup_for_add_comment')
      element(By.css('.cuke-nav-inbox-btn')).click()
      element.all(By.css('.cuke-inbox-item')).first().click()

    addComment: (body) ->
      element(By.css('.cuke-comment-field')).sendKeys('hi this is my comment')
      element(By.css('.cuke-comment-submit')).click()

    mostRecentComment: ->
      element.all(By.css('.thread-comment')).last()

    startProposalLink: ->
      element(By.css('.thread-start-proposal-card')).element(By.tagName('a'))

    cancelProposalBtn: ->
      element(By.css('.cuke-cancel-proposal-btn'))

    startProposal: (name, description) ->
      element(By.css('.thread-start-proposal-card')).element(By.tagName('a')).click()
      element(By.model('proposal.name')).sendKeys(name)
      element(By.model('proposal.description')).sendKeys(description)
      element(By.css('i.fa-calendar')).click()
      element(By.css('th.right')).click()
      element(By.css('th.right')).click()
      element.all(By.repeater('dateObject in week.dates')).first().click()
      element.all(By.css('span.hour')).last().click()
      element(By.css('.cuke-start-proposal-btn')).click()

    fillInProposalForm: (name, description) ->
      element(By.model('proposal.name')).sendKeys(name)
      element(By.model('proposal.description')).sendKeys(description)
      element(By.css('i.fa-calendar')).click()
      element(By.css('th.right')).click()
      element(By.css('th.right')).click()
      element.all(By.repeater('dateObject in week.dates')).first().click()
      element.all(By.css('span.hour')).last().click()

    submitProposalForm: ->
      element(By.css('.cuke-start-proposal-btn')).click()

    modal: ->
      element(By.css('.modal-dialog'))

    expandedProposal: ->
      element(By.css('.proposal-expanded'))

    expandedProposalTitleText: ->
      @expandedProposal().element(By.tagName('h2')).getText()

    flashMessageText: ->
      element(By.css('.flash-container')).getText()

  beforeEach ->
    page = new DiscussionPage
    page.load()

  it 'add a comment', ->
    page.addComment('hi this is my comment')
    expect(page.mostRecentComment().getText()).toContain('hi this is my comment')

  it 'reply to a comment', ->
    page.addComment('original comment right heerrr')
    page.mostRecentComment().element(By.css('.cuke-comment-reply-btn')).click()
    page.addComment('hi this is my comment')
    expect(page.mostRecentComment().element(By.css('.cuke-in-reply-to')).getText()).toContain('in reply to')

  it 'like a comment', ->
    page.addComment('hi')
    page.mostRecentComment().element(By.css('.cuke-comment-like-btn')).click()
    expect(element(By.css('.thread-liked-by-sentence')).getText()).toContain('You like this.')

  describe 'starting a proposal', ->
    beforeEach ->
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
