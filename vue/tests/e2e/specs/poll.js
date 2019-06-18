const moment = require('moment')
require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'can_start_a_proposal_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('test_discussion', { controller: 'polls' })
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--proposal')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .ProseMirror', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')
    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-common-vote-form__button:first-child')
    page.fillIn('.poll-common-vote-form__reason .ProseMirror', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.poll-common-votes-panel__stance-name-and-option', () => {
      page.expectText('.poll-common-votes-panel__stance-name-and-option', 'Agree')
      page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
    })
  },

  'can_start_a_check_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('test_discussion', { controller: 'polls' })
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--count')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .ProseMirror', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-common-vote-form__button:first-child')
    page.fillIn('.poll-common-vote-form__reason .ProseMirror', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.poll-common-stance-choice--count', () => {
      page.expectText('.poll-common-stance-choice__option-name', 'Yes')
      page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
    })
  },

  'can_start_a_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('test_discussion', { controller: 'polls' })
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--poll')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .ProseMirror', 'Some details')
    page.fillIn('.poll-poll-form__add-option-input input', 'An option')
    page.click('.poll-poll-form__option-button')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-common-vote-form__button')
    page.fillIn('.poll-common-vote-form__reason .ProseMirror', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.poll-common-votes-panel__stance-name-and-option', () => {
      page.expectText('.poll-common-stance-choice--poll', 'An option')
      page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
    })
  },

  // TODO: GK: inconsistent for unknown reasons
  // 'can_start_a_dot_vote_in_a_group': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('test_discussion', { controller: 'polls' })
  // page.click('.activity-panel__add-poll')
  //   page.click('.decision-tools-card__poll-type--dot_vote')
  //   // page.click(".poll-common-tool-tip__collapse")
  //   page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  //   page.fillIn('.poll-common-form-fields .ProseMirror', 'Some details')
  //   page.fillIn('.poll-poll-form__add-option-input input', 'An option')
  //
  //   page.click('.poll-poll-form__option-button')
  //   page.click('.poll-common-form__submit')
  //   page.expectElement('.announcement-form__submit')
  //   page.click('.dismiss-modal-button')
  //
  //   page.expectText('.poll-common-card__title', 'A new proposal')
  //   page.expectText('.poll-common-details-panel__details p', 'Some details')
  //
  //   page.scrollTo('.poll-common-card-header', () => {
  //     page.click('.poll-dot-vote-vote-form__dot-button:last-child')
  //     page.click('.poll-dot-vote-vote-form__dot-button:last-child')
  //     page.fillIn('.poll-common-vote-form__reason .ProseMirror', 'A reason')
  //     page.click('.poll-common-vote-form__submit', 1000)
  //   })
  //
  //   page.scrollTo('.poll-common-votes-panel__stance-name-and-option', () => {
  //     page.pause(1000)
  //     page.expectText('.poll-common-stance-choice--dot-vote', 'An option')
  //     page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
  //   })
  // },

  'can_start_a_score_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('test_discussion', { controller: 'polls' })
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--score')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .ProseMirror', 'Some details')
    page.fillIn('.poll-poll-form__add-option-input input', 'An option')
    page.click('.poll-poll-form__option-button')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.fillIn('.poll-score-vote-form__score-input', '4')
    page.fillIn('.poll-common-vote-form__reason .ProseMirror', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.poll-common-votes-panel__stance', () => {
      page.expectText('.poll-common-stance-choice', 'An option')
      page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
    })
  },

  'can_start_a_time_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('test_discussion', { controller: 'polls' })
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--meeting')
    // page.click('.poll-common-tool-tip__collapse')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .ProseMirror', 'Some details')

    page.fillIn('.poll-meeting-time-field__datepicker-container input', moment().format('D MMMM YYYY'))
    page.click('.poll-meeting-time-field__timepicker-container')
    page.fillIn('.poll-meeting-time-field__timepicker-container input', "10:00 am")

    page.click('.poll-meeting-form__option-button')

    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.scrollTo('.poll-common-card-header', () => {
      page.click('.poll-common-vote-form__option button:first-child', 500)
      page.fillIn('.poll-common-vote-form__reason .ProseMirror', 'A reason')
      page.click('.poll-common-vote-form__submit', 1000)
    })

    page.expectElement('.poll-meeting-chart-panel--yes')
    page.scrollTo('.poll-common-votes-panel__stance', () => {
      page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
    })
  },

  'can_start_a_ranked_choice_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('test_discussion', { controller: 'polls' })
    page.click('.activity-panel__add-poll')
    page.click('.decision-tools-card__poll-type--ranked_choice')
    // page.click('.poll-common-tool-tip__collapse')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .ProseMirror', 'Some details')

    page.fillIn('.poll-poll-form__add-option-input input', 'An option')
    page.click('.poll-poll-form__option-button')
    page.fillIn('.poll-poll-form__add-option-input input', 'Another option')
    page.click('.poll-common-form__options .poll-poll-form__option-button:first-child')
    page.click('.poll-common-form__submit')

    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.fillIn('.poll-common-vote-form__reason .ProseMirror', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.poll-common-votes-panel__stance-name-and-option', () => {
      page.expectText('.poll-common-stance-choice--ranked_choice:last-child', 'An option')
      page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
    })
  },

  'can_set_an_outcome': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_closed', { controller: 'polls' })
    page.click('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement .ProseMirror', 'This is an outcome')
    page.click('.poll-common-outcome-form__submit')

    page.expectText('.poll-common-outcome-panel', 'This is an outcome')
  },

  'can_reopen_a_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_closed', { controller: 'polls' })

    page.scrollTo('.poll-actions-dropdown__button', () => {
      page.click('.poll-actions-dropdown__button')
      page.click('.poll-actions-dropdown__reopen')
      page.click('.poll-common-reopen-form__submit')
    })
  },

  'can_start_an_anonymous_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_anonymous', { controller: 'polls' })
    page.click('.show-results-button')

    page.expectText('.poll-common-votes-panel__stance-content', 'Anonymous')
    page.expectNoElement('.poll-common-undecided-panel__button')
  },

  'can_send_a_calendar_invite': (test) => {
    page = pageHelper(test)

    page.loadPath('test_meeting_poll_closed', { controller: 'polls' })
    page.click('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement .ProseMirror', 'Here is a statement')
    page.fillIn('.poll-common-calendar-invite__summary input', 'This is a meeting title')
    page.fillIn('.poll-common-calendar-invite__location input', '123 Any St, USA')
    page.fillIn('.poll-common-calendar-invite__description textarea', 'Here is a meeting agenda')

    page.click('.poll-common-outcome-form__submit')
    page.expectFlash('Outcome created')
    page.expectText('.poll-common-outcome-panel', 'Here is a statement')
  },

  // 'can_invite_users_via_email': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('test_proposal_poll_share', { controller: 'polls' })
  //   page.click('.membership-card__invite')
  //   page.selectFromAutocomplete('.announcement-form__invite input', 'test@example.com')
  //   page.expectText('.announcement-chip__content', 'test@example.com')
  //   page.click('.announcement-form__submit')
  //   page.expectFlash('1 notifications sent')
  // },

  'can_show_undecided_users': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_with_guest', { controller: 'polls' })
    page.expectText('.poll-common-undecided-panel__button', 'Show 5 undecided')
    page.click('.poll-common-undecided-panel__button')
    page.expectText('.poll-common-undecided-panel', 'Undecided (5)')
  },

  'can_remind_undecided_users': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_with_guest_as_author', { controller: 'polls' })
    page.click('.show-results-button')
    page.click('.poll-common-undecided-panel__button')
    page.click('.poll-common-undecided-user__remind')
    page.expectFlash('Reminder notification sent')
  }
}
