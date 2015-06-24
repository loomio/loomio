module.exports = new class ProposalsHelper
  
  startProposalBtn: ->
    element(By.css('.start-proposal-card .start-proposal-button__button'))

  fillInProposalForm: (params) ->
    element(By.css('.proposal-form__title-field')).clear().sendKeys(params.title)
    element(By.css('.proposal-form__details-field')).sendKeys(params.details)

  submitProposalForm: ->
    element(By.css('.proposal-form__start-btn')).click()

  clickAgreeBtn: ->
    element(By.css('.position-button--yes')).click()

  clickChangeBtn: ->
    element.all(By.css('.proposal-positions-panel__change-your-vote')).first().click()

  selectVotePosition: (position) ->
    element(By.css(".vote-form__select-position option[value=#{position}]")).click()

  setVoteStatement: (statement) ->
    element(By.css('.vote-form__statement-field')).clear().sendKeys(statement)

  submitVoteForm: ->
    element(By.css('.vote-form__submit-btn')).click()

  positionsList: ->
    element(By.css('.proposal-positions-panel__list'))

  proposalActionsDropdown: ->
    element(By.css('.proposal-actions-dropdown__btn'))

  proposalActionsDropdownEdit: ->
    element(By.css('.proposal-actions-dropdown__edit-link'))

  proposalActionsDropdownClose: ->
    element(By.css('.proposal-actions-dropdown__close-link'))

  closeProposalButton: ->
    element(By.css('.close-proposal-form__submit-btn'))

  # proposalClosedAt: ->
  #   element(By.css('.cuke-proposal-closed-badge'))

  previousProposalsList: ->
    element(By.css('.previous-proposals-card'))

  saveProposalChangesBtn: ->
    element(By.css('.proposal-form__save-changes-btn'))

  currentProposalHeading: ->
    element(By.css('.proposal-expanded__proposal-name'))

  proposalExpandLink: ->
    element(By.css('a.proposal-collapsed'))

  currentExpandedProposal: ->
    element(By.css('.proposal-expanded'))

  setProposalOutcomeBtn: ->
    element(By.css('.proposal-outcome-panel__set-outcome-btn'))

  fillInProposalOutcomeForm: (params) ->
    element(By.css('.proposal-form__outcome-field')).sendKeys(params.body)

  submitProposalOutcomeForm: ->
    element(By.css('.proposal-outcome-form__publish-outcome-btn')).click()

  currentExpandedProposalOutcome: ->
    element(By.css('.proposal-outcome-panel__outcome'))

  editOutcomeLink: ->
    element(By.css('.proposal-outcome-panel__edit-outcome-link'))

  editProposalOutcomeForm: (params) ->
    element(By.css('.proposal-form__outcome-field')).clear().sendKeys(params.body)

  voteFormPositionSelect: ->
    element(By.css('.vote-form__select-position'))
