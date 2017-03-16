describe 'Polls', ->
  page = require './helpers/page_helper.coffee'

  it 'can start a poll in a group', ->
    page.loadPath 'polls/test_discussion'
    page.click '.decision-tools-card__poll-type--proposal'
    page.fillIn '.poll-proposal-form__title', 'A new proposal'
    page.fillIn '.poll-proposal-form__details', 'Some details'
    page.click '.poll-proposal-form__submit'
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

  it 'can start a standalone poll', ->
    page.loadPath 'polls/start_poll'
    page.click '.poll-common-start-poll__poll-type--proposal'
    page.fillIn '.poll-proposal-form__title', 'A new proposal'
    page.fillIn '.poll-proposal-form__details', 'Some details'
    page.click '.poll-proposal-form__submit'

    page.click '.poll-common-share-form__ok'
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
    page.click '.poll-common-share-form__option-icon'
    browser.driver.sleep(500)

    page.expectFlash 'Invitation email sent to loo@m.io'
