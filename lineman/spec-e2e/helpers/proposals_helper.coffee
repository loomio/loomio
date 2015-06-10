module.exports = new class ProposalsHelper
  
  startProposalBtn: ->
    element(By.css('.start-proposal-card__btn'))

  fillInProposalForm: (params) ->
    element(By.css('.proposal-form__title-field')).clear().sendKeys(params.title)
    element(By.css('.proposal-form__details-field')).sendKeys(params.details)

  submitProposalForm: ->
    element(By.css('.proposal-form__start-btn')).click()

  agreeBtn: ->
    element(By.css('.position-button--yes')).click()

  voteStatementField: ->
    element(By.css('.vote-form__statement-field'))

  submitVoteForm: ->
    element(By.css('.vote-form__submit-btn')).click()

  positionsList: ->
    element(By.css('.proposal-positions__list'))

  proposalActionsDropdown: ->
    element(By.css('.proposal-actions-dropdown__btn'))

  proposalActionsDropdownEdit: ->
    element(By.css('.proposal-actions-dropdown__edit-link'))

  proposalActionsDropdownClose: ->
    element(By.css('.proposal-actions-dropdown__close-link'))

  closeProposalButton: ->
    element(By.css('.close-proposal-form__submit-btn'))

  proposalClosedAt: ->
    element(By.css('.cuke-proposal-closed-badge'))

  previousProposalsList: ->
    element(By.css('.previous-proposals-card'))

  saveProposalChangesBtn: ->
    element(By.css('.proposal-form__save-changes-btn'))

  currentProposalHeading: ->
    element(By.css('.proposal-expanded__proposal-name'))
