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

    page.click '.poll-actions-dropdown'
    page.click '.poll-actions-dropdown__close'
    page.click '.poll-common-close-form__submit'

    page.click '.poll-common-collapsed'
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

    page.click '.poll-common-collapsed'
    page.click '.poll-common-set-outcome-panel__submit'

    page.fillIn '.poll-common-outcome-form__statement', 'This is an outcome'
    page.click  '.poll-common-outcome-form__submit'

    page.expectText '.poll-common-outcome-panel', 'This is an outcome'
