module.exports = class DiscussionPage
  load: ->
    browser.get('http://localhost:8000/angular_support/setup_for_add_comment')

  loadWithActiveProposal: ->
    browser.get('http://localhost:8000/angular_support/setup_for_vote_on_proposal')

  addComment: (body) ->
    element(By.css('#comment-field')).sendKeys('hi this is my comment')
    element(By.css('#post-comment-btn')).click()

  openNotificationDropdown: ->
    element(By.css('.dropdown-toggle')).click()

  notificationDropdown: ->
    element(By.css('.lmo-navbar__btn--notifications'))

  mostRecentComment: ->
    element.all(By.css('.thread-item--comment')).last()

  startProposalLink: ->
    element(By.css('.start-proposal-card__link'))

  cancelProposalBtn: ->
    element(By.css('.proposal-form__cancel-btn'))

  startProposalBtn: ->
    element(By.css('.proposal-form__start-btn'))

  proposalDescripionField: ->
    element(By.model('proposal.description'))

  proposalNameField: ->
    element(By.model('proposal.name'))

  startAProposal: (name, description) ->
    startProposalLink().click()
    proposalNameField().sendKeys(name)
    proposalDescripionField().sendKeys(description)
    startProposalBtn.click()

  #fillInProposalForm: (name, description) ->
    #element(By.model('proposal.name')).clear().sendKeys(name)
    #element(By.model('proposal.description')).clear().sendKeys(description)
    #element(By.css('i.fa-calendar')).click()
    #element(By.css('th.right')).click()
    #element(By.css('th.right')).click()
    #element.all(By.repeater('dateObject in week.dates')).first().click()
    #element.all(By.css('span.hour')).last().click()

  #submitProposalForm: ->
    #element(By.css('.cuke-save-proposal-btn')).click()

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
    element(By.css('.proposal-actions-dropdown__btn'))

  proposalActionsDropdownEdit: ->
    element(By.css('.proposal-actions-dropdown__edit-link'))

  proposalActionsDropdownClose: ->
    element(By.css('.proposal-actions-dropdown__close-link'))

  closeProposalButton: ->
    element(By.css('.close-proposal-form__submit-btn'))

  proposalClosedBadge: ->
    element(By.css('.cuke-proposal-closed-badge'))

  firstCollpasedProposal: ->
    element.all(By.css('a.proposal-collapsed')).first()

