format = require('date-fns/format')
require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'can_start_a_proposal_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-proposal')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')
    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.scrollTo('.poll-common-action-panel', () => {
      page.click('.poll-common-vote-form__button:first-child')
      page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
      page.click('.poll-common-vote-form__submit')
    })

    page.scrollTo('.stance-created', () => {
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_start_a_check_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--count')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-common-vote-form__button:first-child')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.stance-created', () => {
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_start_a_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--poll')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
    page.fillInAndEnter('.poll-poll-form__add-option-input input', 'Another option')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-common-vote-form__button')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.stance-created', () => {
      page.expectText('.poll-common-stance-choice', 'An option')
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_start_a_dot_vote_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--dot_vote')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-dot-vote-vote-form__option .v-slider')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit', 1000)

    page.scrollTo('.poll-common-stance-choice', () => {
      page.expectText('.poll-common-stance-choice--dot_vote', 'An option')
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_start_a_score_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--score')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')

    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-score-vote-form__score-slider .v-slider')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit', 1000)

    page.scrollTo('.stance-created', () => {
      page.expectText('.poll-common-stance-choice--score', 'An option')
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_start_a_time_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--meeting')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-meeting-time-field__datepicker-container input')
    page.click('.poll-meeting-form__option-button')
    page.click('.v-card__title .headline')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-meeting-vote-form--box', 500)
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit', 1000)

    page.scrollTo('.stance-created', () => {
      // page.expectText('.poll-meeting-time', '8am')
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_start_a_ranked_choice_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--ranked_choice')
    // page.click('.poll-common-tool-tip__collapse')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')

    page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
    page.fillInAndEnter('.poll-poll-form__add-option-input input', 'Another option')
    page.click('.poll-common-form__submit')

    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.pause(500)
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.stance-created', () => {
      page.expectText('.poll-common-stance-choice--ranked_choice:first-child', 'An option')
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_set_an_outcome': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_proposal_poll_closed')
    page.click('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]', 'This is an outcome')
    page.click('.poll-common-outcome-form__submit')

    page.expectText('.poll-common-outcome-panel', 'This is an outcome')
  },

  'can_close_and_reopen_a_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-proposal')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')
    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.scrollTo('.poll-common-action-panel', () => {
      page.click('.poll-common-vote-form__button:first-child')
      page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
      page.click('.poll-common-vote-form__submit')
    })

    page.expectText('.poll-common-stance-created__reason', 'A reason')

    page.click('.action-dock__button--close_poll')
    page.click('.confirm-modal__submit', 1000)
    page.click('.dismiss-modal-button')
    page.click('.action-dock__button--reopen_poll')
    page.click('.poll-common-reopen-form__submit')
  },

  'can_start_an_anonymous_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('/polls/test_discussion')
    page.click('.activity-panel__add-proposal')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-settings-anonymous')

    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.click('.show-results-button')
    page.expectText('.poll-common-action-panel__anonymous-message', 'Votes will be anonymous')
  },

  'can_send_a_calendar_invite': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_meeting_poll_closed')
    page.click('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]', 'Here is a statement')
    page.fillIn('.poll-common-calendar-invite__summary input', 'This is a meeting title')
    page.fillIn('.poll-common-calendar-invite__location input', '123 Any St, USA')

    page.click('.poll-common-outcome-form__submit')
    page.expectFlash('Outcome created')
    page.click('.dismiss-modal-button')
    page.expectText('.poll-common-outcome-panel .lmo-markdown-wrapper', 'Here is a statement')
  },

  'can_add_an_option': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--poll')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
    page.fillInAndEnter('.poll-poll-form__add-option-input input', 'Another option')
    page.click('.poll-settings-voterCanAddOptions')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.scrollTo('.poll-common-action-panel', () => {
      page.click('.poll-common-add-option-button button')
    })

    page.fillInAndEnter('.poll-poll-form__add-option-input', 'Yet another option')
    page.click('.poll-add-option__submit')
    page.expectFlash('New options added')
  },

  // 'can_edit_a_vote': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('polls/test_discussion')
  //   page.click('.activity-panel__add-poll')
  //   page.click('.decision-tools-card__poll-type--poll')
  //   // page.click(".poll-common-tool-tip__collapse")
  //   page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  //   page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'Another option')
  //   page.click('.poll-common-form__submit')
  //   page.expectElement('.announcement-form__submit')
  //   page.click('.dismiss-modal-button')
  //
  //   page.expectText('.poll-common-card__title', 'A new proposal')
  //   page.expectText('.poll-common-details-panel__details p', 'Some details')
  //
  //   page.click('.poll-common-vote-form__button')
  //   page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  //   page.click('.poll-common-vote-form__submit')
  //
  //   page.scrollTo('.stance-created', () => {
  //     page.expectText('.poll-common-stance-choice', 'An option')
  //     page.expectText('.poll-common-stance-created__reason', 'A reason')
  //   })
  //
  //   page.click('.action-dock__button--edit_stance')
  //   page.click('.poll-common-edit-vote__button', 500)
  //   page.click('.poll-common-vote-form__button:last-child')
  //   page.click('.poll-common-vote-form__submit')
  //   page.expectFlash('Vote created')
  // },
  //
  // 'can_edit_a_reason': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('polls/test_discussion')
  //   page.click('.activity-panel__add-poll')
  //   page.click('.decision-tools-card__poll-type--poll')
  //   // page.click(".poll-common-tool-tip__collapse")
  //   page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  //   page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'Another option')
  //   page.click('.poll-common-form__submit')
  //   page.expectElement('.announcement-form__submit')
  //   page.click('.dismiss-modal-button')
  //
  //   page.expectText('.poll-common-card__title', 'A new proposal')
  //   page.expectText('.poll-common-details-panel__details p', 'Some details')
  //
  //   page.click('.poll-common-vote-form__button')
  //   page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  //   page.click('.poll-common-vote-form__submit')
  //
  //   page.scrollTo('.stance-created', () => {
  //     page.expectText('.poll-common-stance-choice', 'An option')
  //     page.expectText('.poll-common-stance-created__reason', 'A reason')
  //   })
  //
  //   page.click('.action-dock__button--edit_stance', 500)
  //   page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', "An updated reason")
  //   page.click('.poll-common-edit-vote__submit')
  //   page.expectFlash('Vote updated')
  // },
}
