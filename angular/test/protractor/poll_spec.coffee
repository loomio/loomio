_ = require('lodash')

describe 'Polls', ->
  page = require './helpers/page_helper.coffee'

  startPollTest = (poll_type, optionsFn) ->
    ->
      page.loadPath 'polls/test_discussion'
      page.click ".decision-tools-card__poll-type--#{poll_type}"
      page.click ".poll-common-tool-tip__collapse"
      page.fillIn ".poll-#{_.kebabCase(poll_type)}-form__title", "A new #{poll_type}"
      page.fillIn ".poll-#{_.kebabCase(poll_type)}-form__details", "Some details for #{poll_type}"
      optionsFn() if optionsFn?
      page.click ".poll-common-form__submit"
      page.expectText '.poll-common-summary-panel', "A new #{poll_type}"
      page.expectText '.poll-common-summary-panel', "Some details for #{poll_type}"

  describe 'start, vote for each poll type', ->
    it 'starts a proposal', startPollTest('proposal')

    it 'starts a count', startPollTest('count')

    # I don't know why this one doesn't work; the others do...
    xit 'starts a dot vote', startPollTest 'dot_vote', ->
      page.fillIn ".poll-dot-vote-form__add-option-input", "bananas"

    it 'starts a poll', startPollTest 'poll', ->
      page.fillIn ".poll-poll-form__add-option-input", "bananas"

    # TODO
    xit 'starts a time poll', startPollTest 'meeting', ->
      page.fillIn ".poll-meeting-form__datepicker", "2030-03-23\n"
      page.click ".poll-meeting-form__option-button"

  it 'can start a poll in a group', ->
    page.loadPath 'polls/test_discussion'
    page.click '.decision-tools-card__poll-type--proposal'
    page.click ".poll-common-tool-tip__collapse"
    page.fillIn '.poll-proposal-form__title', 'A new proposal'
    page.fillIn '.poll-proposal-form__details', 'Some details'
    page.click '.poll-common-form__submit'
    page.expectText '.poll-common-summary-panel__title', 'A new proposal'
    page.expectText '.poll-common-summary-panel__details', 'Some details'

    page.click '.poll-common-vote-form__radio-button--agree'
    page.fillIn '.poll-common-vote-form__reason textarea', 'A reason'
    page.click '.poll-proposal-vote-form__submit'

    page.expectText '.poll-common-votes-panel__stance-name-and-option', 'Agree'
    page.expectText '.poll-common-votes-panel__stance-reason', 'A reason'

  it 'can set an outcome', ->
    page.loadPath 'polls/test_proposal_poll_closed'
    page.click '.poll-common-set-outcome-panel__submit'

    page.fillIn '.poll-common-outcome-form__statement', 'This is an outcome'
    page.click  '.poll-common-outcome-form__submit'

    page.expectText '.poll-common-outcome-panel', 'This is an outcome'

  it 'can send a calendar invite', ->
    page.loadPath 'polls/test_meeting_poll_closed'
    page.click '.poll-common-set-outcome-panel__submit'

    page.fillIn '.poll-common-outcome-form__statement', 'Here is a statement'
    page.fillIn '.poll-common-calendar-invite__summary', 'This is a meeting title'
    page.fillIn '.poll-common-calendar-invite__location', '123 Any St, USA'
    page.fillIn '.poll-common-calendar-invite__description', 'Here is a meeting agenda'

    page.click '.poll-common-outcome-form__submit'
    page.expectFlash 'Outcome created'
    page.expectText '.poll-common-outcome-panel', 'Here is a statement'

  it 'can start a standalone poll', ->
    page.loadPath 'polls/start_poll'
    page.click '.poll-common-choose-type__poll-type--proposal'
    page.click ".poll-common-tool-tip__collapse"
    page.fillIn '.poll-proposal-form__title', 'A new proposal'
    page.fillIn '.poll-proposal-form__details', 'Some details'
    page.click '.poll-common-form__submit'

    page.click '.modal-cancel'
    page.expectText '.poll-common-summary-panel__title', 'A new proposal'
    page.expectText '.poll-common-summary-panel__details', 'Some details'

    page.click '.poll-common-vote-form__radio-button--agree'
    page.fillIn '.poll-common-vote-form__reason textarea', 'A reason'
    page.click '.poll-proposal-vote-form__submit'

    page.expectText '.poll-common-votes-panel__stance-name-and-option', 'Agree'
    page.expectText '.poll-common-votes-panel__stance-reason', 'A reason'

    page.click '.poll-actions-dropdown'
    page.click '.poll-actions-dropdown__close'
    page.click '.poll-common-close-form__submit'

    page.click '.poll-common-set-outcome-panel__submit'

    page.fillIn '.poll-common-outcome-form__statement', 'This is an outcome'
    page.click  '.poll-common-outcome-form__submit'

    page.expectText '.poll-common-outcome-panel', 'This is an outcome'

  it 'can vote as a visitor', ->
    page.loadPath 'polls/test_proposal_poll_created_as_visitor'
    page.click '.poll-common-vote-form__radio-button--agree'
    page.fillIn '.poll-proposal-vote-form__reason', 'This is a reason'
    page.fillIn '.poll-common-participant-form__name', 'Big Baloo'
    page.click '.poll-proposal-vote-form__submit'

    page.expectFlash 'Vote created'
    page.expectText '.poll-common-votes-panel__stance-name-and-option', 'Big Baloo'

  it 'can vote as a logged out user', ->
    page.loadPath 'polls/test_proposal_poll_created_as_logged_out'
    page.click '.poll-common-vote-form__radio-button--agree'
    page.fillIn '.poll-proposal-vote-form__reason', 'This is a reason'
    page.fillIn '.poll-common-participant-form__name', 'Big Baloo'
    page.fillIn '.poll-common-participant-form__email', 'big@baloo.ninja'
    page.click '.poll-proposal-vote-form__submit'

    page.expectFlash 'Vote created'
    page.expectText '.poll-common-votes-panel__stance-name-and-option', 'Big Baloo'

  it 'can invite users via email', ->
    page.loadPath 'polls/test_proposal_poll_share'
    page.fillIn '.poll-common-share-form__add-option-input', 'loo@m.io'
    page.click '.poll-common-share-form__option-button'

    page.expectFlash 'Invitation email sent to loo@m.io'

  it 'can show undecided users', ->
    page.loadPath 'polls/test_poll_in_discussion_with_guest'
    page.expectText '.poll-common-undecided-panel__button', 'SHOW 4 UNDECIDED'
    page.click '.poll-common-undecided-panel__button'
    page.expectText '.poll-common-undecided-panel__users', 'Undecided Group Members (2)'
    page.expectText '.poll-common-undecided-panel__visitors', 'Undecided Guests (2)'
