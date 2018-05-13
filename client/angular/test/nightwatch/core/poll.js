require('coffeescript/register')
pageHelper = require('../helpers/page_helper')

module.exports = {
  'can start a poll in a group': (test) => {
    page = pageHelper(test)

    page.loadPath('test_discussion', { controller: 'polls' })
    page.click('.decision-tools-card__poll-type--proposal')
    page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title', 'A new proposal')
    page.fillIn('.poll-common-form-fields textarea', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')
    page.expectNoElement('.poll-common-modal')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details', 'Some details')

    page.click('.poll-common-vote-form__button:first-child')
    page.fillIn('.poll-common-vote-form__reason textarea', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.poll-common-votes-panel__stance-name-and-option', () => {
      page.expectText('.poll-common-votes-panel__stance-name-and-option', 'Agree')
      page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
    })
  },

  'can_start_a_standalone_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('start_poll', { controller: 'polls' })
    page.click('.poll-common-choose-type__poll-type--proposal')
    page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title', 'A new proposal')
    page.fillIn('.poll-common-form-fields textarea', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectElement('.announcement-form__submit')
    page.click('.dismiss-modal-button')
    page.expectNoElement('.poll-common-modal')
    page.pause()

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details', 'Some details')

    page.click('.poll-common-vote-form__button:first-child')
    page.fillIn('.poll-common-vote-form__reason textarea', 'A reason')
    page.click('.poll-common-vote-form__submit')

    page.scrollTo('.poll-common-votes-panel__stance-name-and-option', () => {
      page.expectText('.poll-common-votes-panel__stance-name-and-option', 'Agree')
      page.expectText('.poll-common-votes-panel__stance-reason', 'A reason')
    })

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

    page.loadPath('test_proposal_poll_closed', { controller: 'polls' })
    page.click('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement textarea', 'This is an outcome')
    page.click('.poll-common-outcome-form__submit')

    page.expectText('.poll-common-outcome-panel', 'This is an outcome')
  },

  'can reopen a poll': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_closed', { controller: 'polls' })
    page.scrollTo('.poll-actions-dropdown__button', () => {
      page.click('.poll-actions-dropdown__button')
      page.click('.poll-actions-dropdown__reopen')
      page.click('.poll-common-reopen-form__submit')
    })
  },

  'can start an anonymous poll': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_anonymous', { controller: 'polls' })
    page.click('.show-results-button')
    page.expectText('.poll-common-votes-panel__stance-content', 'Anonymous')
    page.expectNoElement('.poll-common-undecided-panel__button')
  },

  'can send a calendar invite': (test) => {
    page = pageHelper(test)

    page.loadPath('test_meeting_poll_closed', { controller: 'polls' })
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

    page.loadPath('test_proposal_poll_created_as_visitor', { controller: 'polls' })
    page.click('.poll-common-vote-form__button:first-child')
    page.fillIn('.poll-common-participant-form__name', 'Big Baloo')
    page.fillIn('.poll-common-participant-form__email', 'big@baloo.com')
    page.fillIn('.poll-common-vote-form__reason textarea', 'This is a reason')
    page.click('.poll-common-vote-form__submit')

    page.expectText('.flash-root__message', 'Vote created')
    page.expectText('.poll-common-votes-panel__stance-name-and-option', 'Big Baloo')
  },

  'can vote as a logged out user': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_created_as_logged_out', { controller: 'polls' })
    page.click('.poll-common-vote-form__button:first-child')
    page.fillIn('.poll-common-vote-form__reason textarea', 'This is a reason')
    page.fillIn('.poll-common-participant-form__name', 'Big Baloo')
    page.fillIn('.poll-common-participant-form__email', 'big@baloo.ninja')
    page.click('.poll-common-vote-form__submit')

    page.expectText('.flash-root__message', 'Vote created')
    page.expectText('.poll-common-votes-panel__stance-name-and-option', 'Big Baloo')
  },

  'can_invite_users_via_email': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_share', { controller: 'polls' })
    page.click('.membership-card__invite')
    page.selectFromAutocomplete('.announcement-form__invite input', 'test@example.com')
    page.expectText('.announcement-chip__content', 'test@example.com')
    page.click('.announcement-form__submit')
    page.expectText('.flash-root__message', '1 notifications sent')
  },

  'can show undecided users': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_with_guest', { controller: 'polls' })
    page.expectText('.poll-common-undecided-panel__button', 'SHOW 5 UNDECIDED')
    page.click('.poll-common-undecided-panel__button')
    page.expectText('.poll-common-undecided-panel', 'Undecided (5)')
  },

  'can remind undecided users': (test) => {
    page = pageHelper(test)

    page.loadPath('test_proposal_poll_with_guest_as_author', { controller: 'polls' })
    page.click('.show-results-button')
    page.click('.poll-common-undecided-panel__button')
    page.click('.poll-common-undecided-user__remind')
    page.expectText('.flash-root__message', 'Reminder notification sent')
  }
}
