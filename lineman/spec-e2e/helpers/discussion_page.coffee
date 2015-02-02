module.exports = class DiscussionPage
  load: ->
    browser.get('http://localhost:8000/angular_support/setup_for_add_comment')
    element(By.css('.cuke-nav-inbox-btn')).click()
    element.all(By.css('.cuke-inbox-item')).first().click()

  loadWithActiveProposal: ->
    browser.get('http://localhost:8000/angular_support/setup_for_vote_on_proposal')
    element(By.css('.cuke-nav-inbox-btn')).click()
    element.all(By.css('.cuke-inbox-item')).first().click()

  addComment: (body) ->
    element(By.css('.cuke-comment-field')).sendKeys('hi this is my comment')
    element(By.css('.cuke-comment-submit')).click()

  openNotificationDropdown: ->
    element(By.css('.dropdown-toggle')).click()

  notificationDropdown: ->
    element(By.css('.navbar-notifications')).first()

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
    element(By.model('proposal.name')).clear().sendKeys(name)
    element(By.model('proposal.description')).clear().sendKeys(description)
    element(By.css('i.fa-calendar')).click()
    element(By.css('th.right')).click()
    element(By.css('th.right')).click()
    element.all(By.repeater('dateObject in week.dates')).first().click()
    element.all(By.css('span.hour')).last().click()

  submitProposalForm: ->
    element(By.css('.cuke-save-proposal-btn')).click()

  modal: ->
    element(By.css('.modal-dialog'))

  expandedProposal: ->
    element(By.css('.proposal-expanded'))

  expandedProposalTitleText: ->
    @expandedProposal().element(By.tagName('h2')).getText()

  flashMessageText: ->
    element(By.css('.flash-container')).getText()

  agreeWithProposal: (statement) ->
    @agreeButton().click()
    @voteStatementInput().sendKeys(statement)
    @submitPositionButton().click()

  agreeButton: ->
    element(By.css('.position-button-yes'))

  abstainButton: ->
    element(By.css('.position-button-abstain'))

  voteStatementInput: ->
    element(By.model('vote.statement'))

  submitPositionButton: ->
    element(By.css('.cuke-submit-position'))

  editPositionButton: ->
    element(By.css('.cuke-edit-position-btn'))

  yourPositionIcon: ->
    element(By.css('.your-position-icon'))

  yourVoteStatement: ->
    element(By.css('.author-statement'))

  newVoteDiscussionItem: ->
    element(By.css('.thread-new-vote-item'))

  proposalActionsDropdown: ->
    element(By.css('.cuke-proposal-actions-dropdown-btn'))

  proposalActionsDropdownEdit: ->
    element(By.css('.proposal-actions-dropdown')).element(By.css('.cuke-edit-proposal'))

  proposalActionsDropdownClose: ->
    element(By.css('.proposal-actions-dropdown')).element(By.css('.cuke-close-proposal'))

  closeProposalButton: ->
    element(By.css('.cuke-close-proposal-btn'))

  proposalClosedBadge: ->
    element(By.css('.cuke-proposal-closed-badge'))

  firstCollpasedProposal: ->
    element(By.css('.proposal-collapsed a'))

