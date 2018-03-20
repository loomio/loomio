require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

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
  }) },

  'can start a poll in a group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.decision-tools-card__poll-type--proposal')
    page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title', 'A new proposal')
    page.fillIn('.poll-common-form-fields textarea', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details', 'Some details')

    page.click('.poll-common-vote-form__radio-button--agree')
    page.fillIn('.poll-common-vote-form__reason textarea', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.poll-common-votes-panel__stance-name-and-option', () => {
      page.expectText('.poll-common-votes-panel__stance-name-and-option', 'Agree')
      page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
    })
  },

  'can start a standalone poll': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/start_poll')
    page.click('.poll-common-choose-type__poll-type--proposal')
    page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title', 'A new proposal')
    page.fillIn('.poll-common-form-fields textarea', 'Some details')
    page.click('.poll-common-form__submit')

    page.click('.modal-cancel')
    page.pause(2000)
    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details', 'Some details')

    page.click('.poll-common-vote-form__radio-button--agree')
    page.fillIn('.poll-common-vote-form__reason textarea', 'A reason')
    page.click('.poll-common-vote-form__submit')
    page.pause(2000)

    page.expectText('.poll-common-votes-panel__stance-name-and-option', 'Agree')
    page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')

    page.scrollTo('.poll-actions-dropdown__button', () => {
      page.click('.poll-actions-dropdown__button')
      page.click('.poll-actions-dropdown__close')
      page.click('.poll-common-close-form__submit')
    })

    page.fillIn('.poll-common-outcome-form__statement textarea', 'This is an outcome')
    page.click('.poll-common-outcome-form__submit')

    page.expectText('.poll-common-outcome-panel', 'This is an outcome')
  },

  'can set an outcome': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_closed')
    page.click('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement textarea', 'This is an outcome')
    page.click('.poll-common-outcome-form__submit')

    page.expectText('.poll-common-outcome-panel', 'This is an outcome')
  },

  'can reopen a poll': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_closed')
    page.scrollTo('.poll-actions-dropdown__button', () => {
      page.click('.poll-actions-dropdown__button')
      page.click('.poll-actions-dropdown__reopen')
      page.click('.poll-common-reopen-form__submit')
    })
  },

  'can start an anonymous poll': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_anonymous')
    page.click('.show-results-button')
    page.expectText('.poll-common-votes-panel__stance-content', 'Anonymous')
    page.expectNoElement('.poll-common-undecided-panel__button')
  },

  'can send a calendar invite': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_meeting_poll_closed')
    page.click('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement textarea', 'Here is a statement')
    page.fillIn('.poll-common-calendar-invite__summary', 'This is a meeting title')
    page.fillIn('.poll-common-calendar-invite__location', '123 Any St, USA')
    page.fillIn('.poll-common-calendar-invite__description', 'Here is a meeting agenda')

    page.click('.poll-common-outcome-form__submit')
    page.expectText('.flash-root__message', 'Outcome created')
    page.expectText('.poll-common-outcome-panel', 'Here is a statement')
  },

  'can vote as a visitor': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_created_as_visitor')
    page.click('.poll-common-vote-form__radio-button--agree')
    page.fillIn('.poll-common-vote-form__reason textarea', 'This is a reason')
    page.fillIn('.poll-common-participant-form__name', 'Big Baloo')
    page.click('.poll-common-vote-form__submit')

    page.expectText('.flash-root__message', 'Vote created')
    page.expectText('.poll-common-votes-panel__stance-name-and-option', 'Big Baloo')
  },

  'can vote as a logged out user': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_created_as_logged_out')
    page.click('.poll-common-vote-form__radio-button--agree')
    page.fillIn('.poll-common-vote-form__reason textarea', 'This is a reason')
    page.fillIn('.poll-common-participant-form__name', 'Big Baloo')
    page.fillIn('.poll-common-participant-form__email', 'big@baloo.ninja')
    page.click('.poll-common-vote-form__submit')

    page.expectText('.flash-root__message', 'Vote created')
    page.expectText('.poll-common-votes-panel__stance-name-and-option', 'Big Baloo')
  },

  'can invite users via email': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_share')
    page.fillIn('.poll-common-share-form__add-option-input', 'loo@m.io')
    page.click('.poll-common-share-form__option-button')

    page.expectText('.flash-root__message', 'Invitation email sent to loo@m.io')
  },

  'can show undecided users': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_with_guest')
    page.expectText('.poll-common-undecided-panel__button', 'SHOW 5 UNDECIDED')
    page.click('.poll-common-undecided-panel__button')
    page.expectText('.poll-common-undecided-panel', 'Undecided (5)')
    page.expectText('.poll-common-undecided-panel', '1 additional person has been invited to participate via email')
  },

  'can remind undecided users': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_with_guest_as_author')
    page.click('.show-results-button')
    page.click('.poll-common-undecided-panel__button')
    page.click('.poll-common-undecided-user__remind')
    page.expectText('.flash-root__message', 'Reminder notification sent')
  },

  'can resend unaccepted invitations': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_with_guest_as_author')
    page.click('.show-results-button')
    page.click('.poll-common-undecided-panel__button')
    page.click('.poll-common-undecided-panel__show-invitations')
    page.click('.poll-common-undecided-user__resend')
    page.expectText('.flash-root__message', 'Invitation resent')
  }
}

startPollTest = (test, poll_type, optionsFn) => {
  page = pageHelper(test)

  page.loadPath('polls/test_discussion')
  page.click(`.decision-tools-card__poll-type--${poll_type}`)
  page.click(".poll-common-tool-tip__collapse")
  page.fillIn(".poll-common-form-fields__title", `A new ${poll_type}`)
  page.fillIn(".poll-common-form-fields textarea", `Some details for ${poll_type}`)
  if (optionsFn) { optionsFn(page) }
  page.click(".poll-common-form__submit")
  page.expectText('.poll-common-card__title', `A new ${poll_type}`)
  page.expectText('.poll-common-details-panel__details', `Some details for ${poll_type}`)
}
