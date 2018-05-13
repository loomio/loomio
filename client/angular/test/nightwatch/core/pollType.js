require('coffeescript/register')
pageHelper = require('../helpers/page_helper')

module.exports = {
  'starts a proposal': (test) => { startPollTest(test, 'proposal') },
  'starts a count': (test) => { startPollTest(test, 'count') },
  'starts a poll': (test) => { startPollTest(test, 'poll', (page) => {
    page.fillIn(".poll-poll-form__add-option-input", "bananas")
  }) },
  'starts a dot vote': (test) => { startPollTest(test, 'dot_vote', (page) => {
    page.fillIn(".poll-poll-form__add-option-input", "bananas")
  }) },
  'starts a time poll': (test) => { startPollTest(test, 'meeting', (page) => {
    page.fillIn(".poll-meeting-time-field__datepicker input", "2030-03-23")
    page.pause()
  }) },
  'starts a ranked choice': (test) => { startPollTest(test, 'ranked_choice', (page) => {
    page.fillIn(".poll-poll-form__add-option-input", "bananas")
  }) }
}

startPollTest = (test, poll_type, optionsFn) => {
  page = pageHelper(test)

  page.loadPath('test_discussion', { controller: 'polls' })
  page.click(`.decision-tools-card__poll-type--${poll_type}`)
  page.click(".poll-common-tool-tip__collapse")
  page.fillIn(".poll-common-form-fields__title", `A new ${poll_type}`)
  page.fillIn(".poll-common-form-fields textarea", `Some details for ${poll_type}`)
  if (optionsFn) { optionsFn(page) }
  page.click(".poll-common-form__submit")
  page.click(".announcement-form__submit")
  page.expectText('.poll-common-card__title', `A new ${poll_type}`)
  page.expectText('.poll-common-details-panel__details', `Some details for ${poll_type}`)
}
