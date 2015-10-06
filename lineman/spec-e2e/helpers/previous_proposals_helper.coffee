module.exports = new class PreviousProposalsHelper

  load: ->
    browser.get('http://localhost:8000/development/setup_previous_proposal')

  proposalTitle: ->
    element(By.css('.proposal-collapsed__title')).getText()
