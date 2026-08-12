format = require('date-fns/format')
pageHelper = require('../helpers/pageHelper')

module.exports = {
  'can_start_a_proposal_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
    page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectNoElement('.poll-common-form__submit', 8000)
    page.refreshAndWait()
    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-common-vote-form__button-text')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit')
    page.expectText('.poll-common-stance-created__reason', 'A reason')
  },

  'can_start_a_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll')
    page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--poll')
    page.clickAndWait('.decision-tools-card__poll-type--poll', '.poll-common-form-fields__title input')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

    page.click('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'An option')
    page.click('.poll-option-form__done-btn')

    page.click('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'Another option')
    page.click('.poll-option-form__done-btn')

    page.click('.poll-common-form__submit')
    page.expectNoElement('.poll-common-form__submit', 8000)
    page.refreshAndWait()
    // page.expectElement('.poll-members-form__submit')
    page.pause(1000)
    // page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.click('.poll-common-vote-form__button-text')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit')
    page.pause(1000)
    page.expectText('.poll-common-stance-choice', 'An option')
    page.expectText('.poll-common-stance-created__reason', 'A reason')
  },

  'can_start_a_dot_vote_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll')
    page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--dot_vote')
    page.clickAndWait('.decision-tools-card__poll-type--dot_vote', '.poll-common-form-fields__title input')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

    page.click('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'An option')
    page.click('.poll-option-form__done-btn')

    page.click('.poll-common-form__submit')
    page.expectNoElement('.poll-common-form__submit', 8000)
    page.refreshAndWait()
    // page.expectElement('.poll-members-form__submit')
    page.pause(500)
    // page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-dot-vote-vote-form__option .v-slider')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit', 1000)

    page.expectText('.poll-common-stance-choice--dot_vote', 'An option')
    page.expectText('.poll-common-stance-created__reason', 'A reason')
  },

  'can_start_a_score_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll')
    page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--score')
    page.clickAndWait('.decision-tools-card__poll-type--score', '.poll-common-form-fields__title input')
    // page.click(".poll-common-tool-tip__collapse")
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

    page.click('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'An option')
    page.click('.poll-option-form__done-btn')

    page.click('.poll-common-form__submit')
    page.expectNoElement('.poll-common-form__submit', 8000)
    page.refreshAndWait()
    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    page.pause(500)
    // page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    // page.click('.poll-score-vote-form__score-slider .v-slider')
    page.fillIn('.vote-form-number-input', 1)
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit', 1000)

    page.expectText('.poll-common-stance-choice--score', 'An option')
    page.expectText('.poll-common-stance-created__reason', 'A reason')
  },

  'can_start_a_time_poll_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll')
    page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--meeting')
    page.clickAndWait('.decision-tools-card__poll-type--meeting', '.poll-common-form-fields__title input')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-meeting-form__option-button')
    page.click('.poll-common-form__submit')
    page.expectNoElement('.poll-common-form__submit', 8000)
    page.refreshAndWait()
    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    // page.pause(500)
    // page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')

    page.click('.poll-meeting-vote-form--box', 500)
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit', 2000)

    page.expectText('.poll-common-stance-created__reason', 'A reason')
  },

  'can_start_a_ranked_choice_in_a_group': (test) => {
    // skip this test .. it just fails too often.
    return
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.click('.activity-panel__add-poll')
    page.pause(500)
    page.click(".poll-common-choose-template__poll")
    page.click('.decision-tools-card__poll-type--ranked_choice')
    // page.click('.poll-common-tool-tip__collapse')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

    page.click('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'An option')
    page.click('.poll-option-form__done-btn')

    page.click('.poll-common-form__add-option-btn')
    page.fillIn('.poll-option-form__name input', 'Another option')
    page.click('.poll-option-form__done-btn')

    page.click('.poll-common-form__submit')

    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    // page.pause(500)
    // page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
    page.click('.poll-common-vote-form__submit')
    page.pause(900)
    page.expectText('.poll-common-stance-choice--ranked_choice:first-child', 'An option')
    page.expectText('.poll-common-stance-created__reason', 'A reason')
  },

  'can_set_an_outcome': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal')
    page.execute("document.querySelector('.poll-common-set-outcome-panel__submit').scrollIntoView({block: 'center'})")
    page.click('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]', 'This is an outcome')
    page.click('.poll-common-outcome-form__submit')

    page.expectText('.poll-common-outcome-panel', 'This is an outcome')
  },

  // 'can_close_and_reopen_a_poll': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('polls/test_discussion')
  //   page.click('.activity-panel__add-poll')
  //   page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  //   page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  //   page.click('.poll-common-form__submit')
  //   page.expectElement('.poll-members-form__submit')
  //   page.click('.dismiss-modal-button')
  //   page.expectText('.poll-common-card__title', 'A new proposal')
  //   page.expectText('.poll-common-details-panel__details p', 'Some details')
  //
  //   page.scrollTo('.poll-common-action-panel', () => {
  //     page.click('.poll-common-vote-form__button:first-child')
  //     page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  //     page.click('.poll-common-vote-form__submit')
  //   })
  //
  //   page.expectText('.poll-common-stance-created__reason', 'A reason')
  //
  //   page.click('.poll-created .action-menu--btn')
  //   page.click('.action-dock__button--close_poll')
  //   page.click('.confirm-modal__submit', 1000)
  //   page.pause(100)
  //   page.click('.dismiss-modal-button')
  //   page.pause(100)
  //   page.click('.poll-created .action-menu--btn')
  //   page.click('.action-dock__button--reopen_poll')
  //   page.click('.poll-common-reopen-form__submit')
  // },

  'can_start_an_anonymous_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('/polls/test_discussion')
    page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
    page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-common-form__more-settings')
    page.expectText(
      '.poll-common-form__anonymous-voting-explanation',
      'Anonymous votes are stored separately from voter identities. Results only appear after voting closes, and voters cannot add reasons, review their vote after submitting it, or change it.'
    )
    page.expectElement('.poll-common-form__quorum-title ~ .poll-common-form__anonymous-voting-title')
    page.expectElement('.poll-common-form__anonymous-voting-title ~ .poll-common-form__reminder-title')
    page.click('.poll-settings-anonymous .v-selection-control__wrapper')
    page.expectText('.poll-common-settings__notify-on-closing-soon', 'Undecided voters')
    page.expectElement('.poll-common-settings__notify-on-closing-soon.v-input--disabled')
    page.expectText('.poll-common-settings__hide-results', 'Until voting is closed')
    page.expectElement('.poll-common-settings__hide-results.v-input--disabled')
    page.expectText('.poll-common-form__stance-reason-required', 'Disabled')
    page.expectElement('.poll-common-form__stance-reason-required.v-input--disabled')

    page.click('.poll-common-form__submit')
    page.expectNoElement('.poll-common-form__submit', 8000)
    page.refreshAndWait()
    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    // page.pause(500)
    // page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.expectText(
      '.poll-common-action-panel__anonymous-message',
      'Voting is anonymous. You cannot review or change your vote after submitting it. Results are not available until voting has closed.'
    )
    test.expect.element('.poll-common-action-panel__results-hidden-until-closed').to.not.be.present

    page.click('.poll-common-vote-form__button-text')
    page.click('.poll-common-vote-form__submit')
    page.expectText('.poll-common-action-panel__recorded', 'Your vote was recorded')
    page.expectText(
      '.poll-common-action-panel__anonymous-message',
      'Voting is anonymous. You cannot review or change your vote after submitting it. Results are not available until voting has closed.'
    )
    test.expect.element('.poll-common-vote-form').to.not.be.present
    test.expect.element('.poll-common-action-panel__results-hidden-until-closed').to.not.be.present

    page.click('.action-dock__button--close_poll')
    page.click('.confirm-modal__submit')
    page.expectText('.poll-common-action-panel__anonymous-closed-message', 'Votes are anonymous')
    test.expect.element('.poll-common-chart-panel__view-all-votes').to.not.be.present
    page.expectNoElement('.confirm-modal', 5000)
    page.pause(500)

    page.execute("document.querySelector('.poll-common-set-outcome-panel__submit').click()")
    page.click('.recipients-autocomplete input')
    page.expectText('.v-autocomplete__content', 'Everyone invited to vote')
    page.expectNoText('.v-autocomplete__content', 'Everyone who voted')
    page.expectNoText('.v-autocomplete__content', 'Undecided voters')
  },

  'shows_migrated_legacy_anonymous_vote_reasons_without_voter_names': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?scenario=poll_legacy_anonymous&poll_type=proposal')
    page.expectText('.poll-common-chart-panel', 'This poll uses the legacy anonymous voting format')
    test.expect.element('.poll-common-chart-panel__view-all-votes').to.not.be.present
    page.click('.poll-common-chart-panel__view-legacy-vote-reasons')
    page.expectText('.poll-common-votes-panel', 'Legacy vote reasons')
    page.expectText('.poll-common-votes-panel', 'A plain text reason retained from the legacy vote')
    page.expectText('.poll-common-votes-panel__legacy-reason', 'Agree')
    test.expect.element('.poll-common-votes-panel__stance-name-and-option').to.not.be.present
    test.expect.element('.poll-common-votes-panel__avatar').to.not.be.present
  },

  'shows_legacy_anonymous_format_before_migration': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?scenario=poll_legacy_anonymous_stance&poll_type=proposal')
    page.expectText('.poll-common-chart-panel', 'This poll uses the legacy anonymous voting format')
    test.expect.element('.poll-common-chart-panel__view-all-votes').to.be.present
    test.expect.element('.poll-common-chart-panel__view-legacy-vote-reasons').to.not.be.present
  },

  'can_start_a_results_hidden_until_closed_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('/polls/test_discussion')
    page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
    page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-common-form__more-settings')

    page.scrollClick('.poll-common-settings__hide-results .v-field')
    page.waitFor('.v-overlay--active .v-list-item')
    page.clickLastElement('.v-overlay--active .v-list-item')

    // change dropdown here

    page.click('.poll-common-form__submit')
    page.expectNoElement('.poll-common-form__submit', 8000)
    page.refreshAndWait()
    // page.pause(300)
    // page.expectElement('.poll-members-form__submit')
    // page.expectElement('.dismiss-modal-button')
    // page.pause(500)
    // page.click('.dismiss-modal-button')

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.expectElement('.poll-common-action-panel__results-hidden-until-closed')
    // poll-common-action-panel__results-hidden-until-closed
  },

  'can_remove_own_vote': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?poll_type=proposal&scenario=poll_closing_soon_with_vote')
    page.execute("document.querySelector('.action-menu--btn').scrollIntoView({block: 'center'})")
    page.click('.action-menu--btn')
    page.click('.action-dock__button--uncast_stance')
    page.expectText('.confirm-modal', 'Remove your vote?')
    page.click('.confirm-modal__submit')
    page.expectFlash('Vote removed')
  },

  'can_send_a_calendar_invite': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?scenario=poll_closed&poll_type=meeting')
    page.execute("document.querySelector('.poll-common-set-outcome-panel__submit').scrollIntoView({block: 'center'})")
    page.click('.poll-common-set-outcome-panel__submit')

    page.fillIn('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]', 'Here is a statement')
    page.fillIn('.poll-common-calendar-invite__summary input', 'This is a meeting title')
    page.fillIn('.poll-common-calendar-invite__location input', '123 Any St, USA')

    page.click('.poll-common-outcome-form__submit')
    page.expectFlash('Outcome created')
    // page.click('.dismiss-modal-button')
    // page.expectText('.poll-common-outcome-panel .lmo-markdown-wrapper', 'Here is a statement')
  },

  'can_invite_non_member_to_anonymous_proposal_in_a_group': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('polls/test_poll_scenario.email?poll_type=proposal&scenario=poll_created&anonymous=1&guest=1')
    page.click('.event-mailer__title a')
    page.pause(1000)
    page.click('.poll-common-vote-form__button-text')
    page.fillIn('.html-editor__textarea .ProseMirror', "reason")
    page.click('.poll-common-vote-form__submit')
    page.expectFlash('Vote created')
    // page.click('.dismiss-modal-button')
  },

  'can_start_a_specified_voters_only_proposal': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
    page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-common-settings__specified-voters-only .v-selection-control__wrapper')
    page.click('.poll-common-form__submit')

    page.expectElement('.poll-members-form')
    page.fillIn('.recipients-autocomplete input', 'test@example.com')
    page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
    page.click('.recipients-autocomplete-suggestion')
    page.escape()
    // page.expectElement('.text-h5')
    page.click('.poll-members-form__submit')
    page.expectText('.poll-members-form__list', 'test@example.com')
    page.click('.dismiss-modal-button')
    page.refreshAndWait()

    page.expectText('.poll-common-card__title', 'A new proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
    page.expectText('.poll-common-unable-to-vote', 'You have not been invited to vote')
  },

  // 'can_edit_a_vote': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('polls/test_discussion')
  //   page.click('.activity-panel__add-poll')
  //   page.click('.decision-tools-card__poll-type--poll')
  //   // page.click(".poll-common-tool-tip__collapse")
  //   page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  //   page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'Another option')
  //   page.click('.poll-common-form__submit')
  //   page.expectElement('.poll-members-form__submit')
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
  //   page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'An option')
  //   page.fillInAndEnter('.poll-poll-form__add-option-input input', 'Another option')
  //   page.click('.poll-common-form__submit')
  //   page.expectElement('.poll-members-form__submit')
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

  'can_create_a_scheduled_proposal': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_discussion')
    page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
    page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
    page.fillIn('.poll-common-form-fields__title input', 'A scheduled proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

    // Uncheck "opens immediately" to schedule the poll for the future
    page.click('.poll-common-form__opens-immediately .v-selection-control__wrapper')
    page.pause(500)

    page.click('.poll-common-form__submit')
    page.expectNoElement('.poll-common-form__submit', 8000)
    page.refreshAndWait()

    // Poll should show scheduled voting info (not "Closing in...")
    page.expectText('.poll-common-action-panel__scheduled', 'opens for voting')

    // Vote form should show as a non-interactive preview
    page.expectElement('.poll-common-vote-form--preview')
    // Verify the poll options are visible
    page.expectElement('.poll-common-vote-form__button')
  },

  'can_view_scheduled_poll_and_add_voters': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_scheduled_poll')
    page.pause(500)

    // Verify the poll shows scheduled voting info
    page.expectText('.poll-common-action-panel__scheduled', 'opens for voting')

    // Vote form should show as a non-interactive preview with options visible
    page.expectElement('.poll-common-vote-form--preview')
    page.expectElement('.poll-common-vote-form__button')

    // Open the add voters modal
    page.click('.action-dock__button--announce_poll')
    page.pause(500)

    // Verify the add voters modal is shown
    page.expectElement('.poll-members-form')

    // Verify the add voters button label
    page.expectText('.poll-members-form__submit', 'Add voters')
  },

  'can_start_a_standalone_poll': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/start_poll')
    page.expectElement('.poll-common-choose-template')
    page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
    page.fillIn('.poll-common-form-fields__title input', 'A standalone proposal')
    page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectText('.context-panel__heading', 'A standalone proposal')
    page.expectText('.poll-common-details-panel__details p', 'Some details')
  },
}
