format = require('date-fns/format')
pageHelper = require('../helpers/pageHelper')

module.exports = {
  'can_start_a_proposal_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.scrollClick('.decision-tools-card__poll-type--proposal')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.scrollClick('.poll-common-form__submit')
    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.scrollTo('.poll-common-action-panel', () => {
      page.scrollClick('.poll-common-vote-form__button-text')
      page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
      page.scrollClick('.poll-common-vote-form__submit')
    })

    page.scrollTo('.stance-created', () => {
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_start_a_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.scrollClick('.activity-panel__add-poll')
    page.scrollClick(".poll-common-choose-template__poll")
    page.scrollClick('.decision-tools-card__poll-type--poll')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

    page.scrollClick('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'An option')
    page.scrollClick('.poll-option-form__done-btn')

    page.scrollClick('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'Another option')
    page.scrollClick('.poll-option-form__done-btn')

    page.scrollClick('.poll-common-form__submit')
    // page.expectElement('.poll-members-form__submit')
    page.pause(1000)
    // page.scrollClick('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.scrollClick('.poll-common-vote-form__button-text')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.scrollClick('.poll-common-vote-form__submit')
    page.pause(1000)
    page.expectText('.poll-common-stance-choice', 'An option')
    page.expectText('.poll-common-stance-created__reason', 'A reason')
  },

  'can_start_a_dot_vote_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.click(".poll-common-choose-template__poll")
    page.click('.decision-tools-card__poll-type--dot_vote')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

    page.click('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'An option')
    page.click('.poll-option-form__done-btn')

    page.click('.poll-common-form__submit')
    // page.expectElement('.poll-members-form__submit')
    page.pause(500)
    // page.click('.dismiss-modal-button')

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
    page.scrollClick('.activity-panel__add-poll')
    page.scrollClick(".poll-common-choose-template__poll")
    page.scrollClick('.decision-tools-card__poll-type--score')
    // page.scrollClick(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

    page.scrollClick('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'An option')
    page.scrollClick('.poll-option-form__done-btn')

    page.scrollClick('.poll-common-form__submit')
    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    page.pause(500)
    // page.scrollClick('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.scrollClick('.poll-score-vote-form__score-slider .v-slider')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.scrollClick('.poll-common-vote-form__submit', 1000)

    page.scrollTo('.stance-created', () => {
      page.expectText('.poll-common-stance-choice--score', 'An option')
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_start_a_time_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.scrollClick('.activity-panel__add-poll')
    page.scrollClick(".poll-common-choose-template__meeting")
    page.scrollClick('.decision-tools-card__poll-type--meeting')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.scrollClick('.poll-meeting-form__option-button')
    page.scrollClick('.poll-common-form__submit')
    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    // page.pause(500)
    // page.scrollClick('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.scrollClick('.poll-meeting-vote-form--box', 500)
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.scrollClick('.poll-common-vote-form__submit', 2000)

    page.scrollTo('.stance-created', () => {
      // page.expectText('.poll-meeting-time', '8am')
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_start_a_ranked_choice_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.scrollClick('.activity-panel__add-poll')
    page.scrollClick(".poll-common-choose-template__poll")
    page.scrollClick('.decision-tools-card__poll-type--ranked_choice')
    // page.scrollClick('.poll-common-tool-tip__collapse')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

    page.scrollClick('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'An option')
    page.scrollClick('.poll-option-form__done-btn')

    page.scrollClick('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'Another option')
    page.scrollClick('.poll-option-form__done-btn')
    
    page.scrollClick('.poll-common-form__submit')

    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    // page.pause(500)
    // page.scrollClick('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.pause(500)
    page.scrollClick('.poll-common-vote-form__submit')

    page.scrollTo('.stance-created', () => {
      page.expectText('.poll-common-stance-choice--ranked_choice:first-child', 'An option')
      page.expectText('.poll-common-stance-created__reason', 'A reason')
    })
  },

  'can_set_an_outcome': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal')
    page.scrollClick('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]', 'This is an outcome')
    page.scrollClick('.poll-common-outcome-form__submit')

    page.expectText('.poll-common-outcome-panel', 'This is an outcome')
  },

  // 'can_close_and_reopen_a_poll': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('polls/test_discussion')
  //   page.scrollClick('.activity-panel__add-poll')
  //   page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  //   page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  //   page.scrollClick('.poll-common-form__submit')
  //   page.expectElement('.poll-members-form__submit')
  //   page.scrollClick('.dismiss-modal-button')
  //   page.expectText('.poll-common-card__title', 'A new proposal')
  //   page.expectText('.poll-common-details-panel__details p', 'Some details')
  //
  //   page.scrollTo('.poll-common-action-panel', () => {
  //     page.scrollClick('.poll-common-vote-form__button:first-child')
  //     page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  //     page.scrollClick('.poll-common-vote-form__submit')
  //   })
  //
  //   page.expectText('.poll-common-stance-created__reason', 'A reason')
  //
  //   page.scrollClick('.poll-created .action-menu--btn')
  //   page.scrollClick('.action-dock__button--close_poll')
  //   page.scrollClick('.confirm-modal__submit', 1000)
  //   page.pause(100)
  //   page.scrollClick('.dismiss-modal-button')
  //   page.pause(100)
  //   page.scrollClick('.poll-created .action-menu--btn')
  //   page.scrollClick('.action-dock__button--reopen_poll')
  //   page.scrollClick('.poll-common-reopen-form__submit')
  // },

  'can_start_an_anonymous_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('/polls/test_discussion')
    page.scrollClick('.activity-panel__add-poll')
    page.scrollClick('.decision-tools-card__poll-type--proposal')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.scrollClick('.poll-common-form__advanced-btn')
    page.scrollClick('.poll-settings-anonymous')

    page.scrollClick('.poll-common-form__submit')
    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    // page.pause(500)
    // page.scrollClick('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.expectText('.poll-common-action-panel__anonymous-message', 'Votes are anonymous')
  },

  'can_start_a_results_hidden_until_closed_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('/polls/test_discussion')
    page.scrollClick('.activity-panel__add-poll')
    page.scrollClick('.decision-tools-card__poll-type--proposal')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    // page.scrollClick('.poll-settings-hide-results-until-closed')

    page.scrollClick('.poll-common-form__advanced-btn')
    page.scrollClick('.poll-common-settings__hide-results')
    page.scrollClick('.v-select-list .v-list-item:last-child')

    // change dropdown here

    page.scrollClick('.poll-common-form__submit')
    // page.pause(300)
    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    // page.pause(500)
    // page.scrollClick('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.expectElement('.poll-common-action-panel__results-hidden-until-closed')
  },

  'can_remove_own_vote': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?poll_type=proposal&scenario=poll_closing_soon_with_vote')
    page.scrollClick('.action-menu--btn')
    page.scrollClick('.action-dock__button--uncast_stance')
    page.expectText('.confirm-modal', 'Remove your vote?')
    page.scrollClick('.confirm-modal__submit')
    page.expectFlash('Vote removed')
  },

  'can_send_a_calendar_invite': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?scenario=poll_closed&poll_type=meeting')
    page.scrollClick('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]', 'Here is a statement')
    page.fillIn('.poll-common-calendar-invite__summary input', 'This is a meeting title')
    page.fillIn('.poll-common-calendar-invite__location input', '123 Any St, USA')

    page.scrollClick('.poll-common-outcome-form__submit')
    page.expectFlash('Outcome created')
    // page.scrollClick('.dismiss-modal-button')
    // page.expectText('.poll-common-outcome-panel .lmo-markdown-wrapper', 'Here is a statement')
  },

  'can_add_standalone_poll_to_thread': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?poll_type=proposal&scenario=poll_created&standalone=1&admin=1')
    page.scrollClick('.action-menu')
    page.scrollClick('.action-dock__button--add_poll_to_thread')
    page.fillIn('.add-to-thread-modal__search input', "Some")
    page.pause(1000)
    page.scrollClick('.v-autocomplete__content .v-list-item__content')
    page.scrollClick('.add-to-thread-modal__submit')
    page.expectFlash("Success, proposal added to thread!")
  },

  'can_invite_non_member_to_anonymous_proposal_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('polls/test_poll_scenario?poll_type=proposal&scenario=poll_created&email=1&anonymous=1&guest=1')
    page.scrollClick('.event-mailer__title a')
    page.pause(1000)
    page.scrollClick('.poll-common-vote-form__button-text')
    page.fillIn('.html-editor__textarea .ProseMirror', "reason")
    page.scrollClick('.poll-common-vote-form__submit')
    page.expectFlash('Vote created')
    // page.scrollClick('.dismiss-modal-button')
  },

  'can_start_a_specified_voters_only_proposal': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.scrollClick('.activity-panel__add-poll')
    page.scrollClick('.decision-tools-card__poll-type--proposal')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.scrollClick('.poll-common-settings__specified-voters-only')
    page.scrollClick('.poll-common-form__submit')

    page.expectElement('.poll-members-form')
    page.fillIn('.recipients-autocomplete input', 'test@example.com')
    page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
    page.scrollClick('.recipients-autocomplete-suggestion')
    page.escape()
    page.expectElement('.text-h5')
    page.scrollClick('.poll-members-form__submit')
    page.expectText('.poll-members-form__list', 'test@example.com')
    page.scrollClick('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.expectText('.poll-common-unable-to-vote', 'You have not been invited to vote')
  },

  // 'can_edit_a_vote': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('polls/test_discussion')
  //   page.scrollClick('.activity-panel__add-poll')
  //   page.scrollClick('.decision-tools-card__poll-type--poll')
  //   // page.scrollClick(".poll-common-tool-tip__collapse")
  //   page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  //   page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'Another option')
  //   page.scrollClick('.poll-common-form__submit')
  //   page.expectElement('.poll-members-form__submit')
  //   page.scrollClick('.dismiss-modal-button')
  //
  //   page.expectText('.poll-common-card__title', 'A new proposal')
  //   page.expectText('.poll-common-details-panel__details p', 'Some details')
  //
  //   page.scrollClick('.poll-common-vote-form__button')
  //   page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  //   page.scrollClick('.poll-common-vote-form__submit')
  //
  //   page.scrollTo('.stance-created', () => {
  //     page.expectText('.poll-common-stance-choice', 'An option')
  //     page.expectText('.poll-common-stance-created__reason', 'A reason')
  //   })
  //
  //   page.scrollClick('.action-dock__button--edit_stance')
  //   page.scrollClick('.poll-common-edit-vote__button', 500)
  //   page.scrollClick('.poll-common-vote-form__button:last-child')
  //   page.scrollClick('.poll-common-vote-form__submit')
  //   page.expectFlash('Vote created')
  // },
  //
  // 'can_edit_a_reason': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('polls/test_discussion')
  //   page.scrollClick('.activity-panel__add-poll')
  //   page.scrollClick('.decision-tools-card__poll-type--poll')
  //   // page.scrollClick(".poll-common-tool-tip__collapse")
  //   page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  //   page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'Another option')
  //   page.scrollClick('.poll-common-form__submit')
  //   page.expectElement('.poll-members-form__submit')
  //   page.scrollClick('.dismiss-modal-button')
  //
  //   page.expectText('.poll-common-card__title', 'A new proposal')
  //   page.expectText('.poll-common-details-panel__details p', 'Some details')
  //
  //   page.scrollClick('.poll-common-vote-form__button')
  //   page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  //   page.scrollClick('.poll-common-vote-form__submit')
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
