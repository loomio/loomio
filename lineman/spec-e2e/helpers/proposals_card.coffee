module.exports = class ProposalsCard
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

  expandedProposal: ->
    element(By.css('.proposal-expanded'))

  expandedProposalTitleText: ->
    @expandedProposal().element(By.tagName('h2')).getText()

  flashMessageText: ->
    element(By.css('.flash-container')).getText()
