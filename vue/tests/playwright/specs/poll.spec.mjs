import { test, expect } from '../fixtures.mjs';


test('identified_vote_form_disappears_after_voting_without_a_reason', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_created&poll_type=proposal')
  await page.click('.poll-common-vote-form__button-text')
  await page.click('.poll-common-vote-form__submit')
  await page.expectNoElement('.poll-common-vote-form', 5000)
  await page.expectElement('.poll-common-current-vote')
});

test('can_start_a_proposal_in_a_group', async ({ lmo: page }) => {
  await page.loadPath('polls/test_discussion')
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
  await page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  await page.click('.poll-common-form__submit')
  await page.expectNoElement('.poll-common-form__submit', 8000)
  await page.refreshAndWait()
  await page.expectText('.poll-common-card__title', 'A new proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')

  await page.click('.poll-common-vote-form__button-text')
  await page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit')
  await page.expectText('.poll-common-stance-created__reason', 'A reason')
  await page.expectElement('.poll-created .poll-common-chart-panel ~ .poll-common-action-panel .poll-common-current-vote')
});

test('can_start_a_poll_in_a_group', async ({ lmo: page }) => {
  await page.loadPath('polls/test_discussion')
  await page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll')
  await page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--poll')
  await page.clickAndWait('.decision-tools-card__poll-type--poll', '.poll-common-form-fields__title input')
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

  await page.click('.poll-common-form__add-option-btn')
  await page.fillIn('.poll-option-form__name input', 'An option')
  await page.click('.poll-option-form__done-btn')

  await page.click('.poll-common-form__add-option-btn')
  await page.fillIn('.poll-option-form__name input', 'Another option')
  await page.click('.poll-option-form__done-btn')

  await page.click('.poll-common-form__submit')
  await page.expectNoElement('.poll-common-form__submit', 8000)
  await page.refreshAndWait()
  // page.expectElement('.poll-members-form__submit')
  await page.pause(1000)
  // page.click('.dismiss-modal-button')

  await page.expectText('.poll-common-card__title', 'A new proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')
  await page.click('.poll-common-vote-form__button-text')
  await page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit')
  await page.pause(1000)
  await page.expectText('.poll-common-stance-choice', 'An option')
  await page.expectText('.poll-common-stance-created__reason', 'A reason')
});

test('shows_none_of_the_above_as_the_current_vote', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_none_of_the_above')
  await page.expectText('.poll-common-current-vote', 'None of the above')
});

test('can_start_a_dot_vote_in_a_group', async ({ lmo: page }) => {
  await page.loadPath('polls/test_discussion')
  await page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll')
  await page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--dot_vote')
  await page.clickAndWait('.decision-tools-card__poll-type--dot_vote', '.poll-common-form-fields__title input')
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

  await page.click('.poll-common-form__add-option-btn')
  await page.fillIn('.poll-option-form__name input', 'An option')
  await page.click('.poll-option-form__done-btn')

  await page.click('.poll-common-form__submit')
  await page.expectNoElement('.poll-common-form__submit', 8000)
  await page.refreshAndWait()
  // page.expectElement('.poll-members-form__submit')
  await page.pause(500)
  // page.click('.dismiss-modal-button')

  await page.expectText('.poll-common-card__title', 'A new proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')

  await page.click('.poll-dot-vote-vote-form__option .v-slider')
  await page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit', 1000)

  await page.expectText('.poll-common-stance-choice--dot_vote', 'An option')
  await page.expectText('.poll-common-stance-created__reason', 'A reason')
});

test('can_start_a_score_poll_in_a_group', async ({ lmo: page }) => {
  await page.loadPath('polls/test_discussion')
  await page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll')
  await page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--score')
  await page.clickAndWait('.decision-tools-card__poll-type--score', '.poll-common-form-fields__title input')
  // page.click(".poll-common-tool-tip__collapse")
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

  await page.click('.poll-common-form__add-option-btn')
  await page.fillIn('.poll-option-form__name input', 'An option')
  await page.click('.poll-option-form__done-btn')

  await page.click('.poll-common-form__submit')
  await page.expectNoElement('.poll-common-form__submit', 8000)
  await page.refreshAndWait()
  // page.expectElement('.poll-members-form__submit')
  // page.expectElement('.dismiss-modal-button')
  await page.pause(500)
  // page.click('.dismiss-modal-button')

  await page.expectText('.poll-common-card__title', 'A new proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')

  // page.click('.poll-score-vote-form__score-slider .v-slider')
  await page.fillIn('.vote-form-number-input', 1)
  await page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit', 1000)

  await page.expectText('.poll-common-stance-choice--score', 'An option')
  await page.expectText('.poll-common-stance-created__reason', 'A reason')
});

test('can_start_a_time_poll_in_a_group', async ({ lmo: page }) => {
  await page.loadPath('polls/test_discussion?time_zone=America%2FLos_Angeles')
  await page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll')
  await page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--meeting')
  await page.clickAndWait('.decision-tools-card__poll-type--meeting', '.poll-common-form-fields__title input')
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  await page.expectText('.date-time-picker', 'America/Los_Angeles')
  await page.clearField('.date-time-picker__time-field input[role="combobox"]');
  await page.fillIn('.date-time-picker__time-field input[role="combobox"]', '07:30')
  await page.expectText('.date-time-picker', '7:30 AM')
  await page.click('.poll-meeting-form__option-button')
  await page.click('.poll-common-form__submit')
  await page.expectNoElement('.poll-common-form__submit', 8000)
  await page.refreshAndWait()
  // page.expectElement('.poll-members-form__submit')
  // page.expectElement('.dismiss-modal-button')
  // page.pause(500)
  // page.click('.dismiss-modal-button')

  await page.expectText('.poll-common-card__title', 'A new proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')
  await page.expectText('.poll-meeting-time', '7:30AM')

  await page.click('.poll-meeting-vote-form--box', 500)
  await page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit', 2000)

  await page.expectText('.poll-common-stance-created__reason', 'A reason')
});

test('can_start_a_ranked_choice_in_a_group', async ({ lmo: page }) => {
  // skip this test .. it just fails too often.
  return

  await page.loadPath('polls/test_discussion')
  await page.click('.activity-panel__add-poll')
  await page.pause(500)
  await page.click(".poll-common-choose-template__poll")
  await page.click('.decision-tools-card__poll-type--ranked_choice')
  // page.click('.poll-common-tool-tip__collapse')
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

  await page.click('.poll-common-form__add-option-btn')
  await page.fillIn('.poll-option-form__name input', 'An option')
  await page.click('.poll-option-form__done-btn')

  await page.click('.poll-common-form__add-option-btn')
  await page.fillIn('.poll-option-form__name input', 'Another option')
  await page.click('.poll-option-form__done-btn')

  await page.click('.poll-common-form__submit')

  // page.expectElement('.poll-members-form__submit')
  // page.expectElement('.dismiss-modal-button')
  // page.pause(500)
  // page.click('.dismiss-modal-button')

  await page.expectText('.poll-common-card__title', 'A new proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')
  await page.fillIn('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]', 'A reason')
  await page.click('.poll-common-vote-form__submit')
  await page.pause(900)
  await page.expectText('.poll-common-stance-choice--ranked_choice:first-child', 'An option')
  await page.expectText('.poll-common-stance-created__reason', 'A reason')
});

test('can_set_an_outcome', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal')
  await page.execute("document.querySelector('.poll-common-set-outcome-panel__submit').scrollIntoView({block: 'center'})")
  await page.click('.poll-common-set-outcome-panel__submit')

  await page.fillIn('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]', 'This is an outcome')
  await page.click('.poll-common-outcome-form__submit')

  await page.expectText('.poll-common-outcome-panel', 'This is an outcome')
});

test('opens_reminder_form_after_reopening_a_poll', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal')
  await page.execute("Array.from(document.querySelectorAll('.poll-created .action-menu--btn')).find(el => el.offsetParent).click()")
  await page.waitFor('.action-dock__button--reopen_poll')
  await page.execute("Array.from(document.querySelectorAll('.action-dock__button--reopen_poll')).find(el => el.offsetParent).click()")
  await page.clickAndWait('.poll-common-reopen-form__submit', '.poll-remind')
  await page.expectText('.poll-remind', 'Remind to vote')
});

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

test('can_start_an_anonymous_poll', async ({ lmo: page }) => {
  await page.loadPath('/polls/test_discussion')
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
  await page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  await page.click('.poll-common-form__more-settings')
  await page.expectText(
    '.poll-common-form__anonymous-voting-explanation',
    'Anonymous votes are stored separately from voter identities. Results only appear after voting closes, and voters cannot add reasons, review their vote after submitting it, or change it.'
  )
  await page.expectElement('.poll-common-form__anonymous-voting-title ~ .poll-common-form__weighted-voting-title')
  await page.expectElement('.poll-common-form__weighted-voting-title ~ .poll-common-form__quorum-title')
  await page.expectElement('.poll-common-form__quorum-title ~ .poll-common-form__reminder-title')
  await page.click('.poll-settings-anonymous .v-selection-control__wrapper')
  await page.expectText('.poll-common-settings__notify-on-closing-soon', "People who haven't voted")
  await page.expectElement('.poll-common-settings__notify-on-closing-soon.v-input--disabled')
  await page.expectText('.poll-common-settings__hide-results', 'Until voting is closed')
  await page.expectElement('.poll-common-settings__hide-results.v-input--disabled')
  await page.expectText('.poll-common-form__stance-reason-required', 'Disabled')
  await page.expectElement('.poll-common-form__stance-reason-required.v-input--disabled')

  await page.click('.poll-common-form__submit')
  await page.expectNoElement('.poll-common-form__submit', 8000)
  await page.refreshAndWait()
  // page.expectElement('.poll-members-form__submit')
  // page.expectElement('.dismiss-modal-button')
  // page.pause(500)
  // page.click('.dismiss-modal-button')

  await page.expectText('.poll-common-card__title', 'A new proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')
  await page.expectText(
    '.poll-common-action-panel__anonymous-message',
    'Voting is anonymous. You cannot review or change your vote after submitting it. Results are not available until voting has closed.'
  )
  await page.expectNoElement('.poll-common-action-panel__results-hidden-until-closed');

  await page.click('.poll-common-vote-form__button-text')
  await page.click('.poll-common-vote-form__submit')
  await page.expectText('.poll-common-action-panel__recorded', 'Your vote was recorded')
  await page.expectText(
    '.poll-common-action-panel__anonymous-message',
    'Voting is anonymous. You cannot review or change your vote after submitting it. Results are not available until voting has closed.'
  )
  await page.expectNoElement('.poll-common-vote-form');
  await page.expectNoElement('.poll-common-action-panel__results-hidden-until-closed');
  await page.expectNoElement('.action-dock__button--view_votes');

  await page.click('.action-dock__button--close_poll')
  await page.click('.confirm-modal__submit')
  await page.expectText('.poll-common-action-panel__anonymous-closed-message', 'Votes are anonymous')
  await page.expectElement('.action-dock__button--view_votes')
  await page.expectNoElement('.confirm-modal', 5000)
  await page.pause(500)

  await page.execute("document.querySelector('.poll-common-set-outcome-panel__submit').click()")
  await page.click('.recipients-autocomplete input[type="text"]')
  await page.expectText('.v-autocomplete__content', 'Everyone invited to vote')
  await page.expectNoText('.v-autocomplete__content', 'Everyone who voted')
  await page.expectNoText('.v-autocomplete__content', "People who haven't voted")
});

test('shows_migrated_legacy_anonymous_participation_without_vote_reasons', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_legacy_anonymous&poll_type=proposal')
  await page.clickAndWait('.action-dock__button--view_votes', '.poll-common-votes-panel')
  await page.expectElement('.poll-common-votes-panel table')
  await page.expectNoText('.poll-common-votes-panel', 'A plain text reason retained from the legacy vote')
});

test('shows_identified_votes_in_a_table', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal')
  await page.clickAndWait('.action-dock__button--view_votes', '.poll-common-votes-panel table tbody tr')
  await page.expectElement('.v-container--fluid .votes-page')
  await page.expectText('.topic-header h1', 'Votes')
  await page.expectNoText('.topic-header .v-breadcrumbs', 'Votes')
  await page.expectText('.poll-common-votes-panel table thead', 'Name')
  await page.expectText('.poll-common-votes-panel table thead', 'Vote')
  await page.expectNoText('.poll-common-votes-panel table thead', 'Voted on')
});

test('can_start_a_results_hidden_until_closed_poll', async ({ lmo: page }) => {
  await page.loadPath('/polls/test_discussion')
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
  await page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  // Wait for More settings to finish expanding, so the field stays put while it is clicked.
  await page.clickAndWait('.poll-common-form__more-settings', '.poll-common-settings__hide-results')
  await page.expectNoElement('.expand-transition-enter-active');
  await page.execute("document.querySelector('.poll-common-settings__hide-results').scrollIntoView({block: 'center'})")
  await page.click('.poll-common-settings__hide-results .v-field')
  await page.waitFor('.v-overlay--active .v-list-item')
  await page.clickLastElement('.v-overlay--active .v-list-item')

  // change dropdown here

  await page.click('.poll-common-form__submit')
  await page.expectNoElement('.poll-common-form__submit', 8000)
  await page.refreshAndWait()
  // page.pause(300)
  // page.expectElement('.poll-members-form__submit')
  // page.expectElement('.dismiss-modal-button')
  // page.pause(500)
  // page.click('.dismiss-modal-button')

  await page.expectText('.poll-common-card__title', 'A new proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')
  await page.expectElement('.poll-common-action-panel__results-hidden-until-closed')
  // poll-common-action-panel__results-hidden-until-closed
});

test('can_remove_own_vote', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?poll_type=proposal&scenario=poll_closing_soon_with_vote')
  // The thread header has its own action menu, so target the poll's.
  await page.waitFor('.poll-created .action-menu--btn')
  await page.execute("document.querySelector('.poll-created .action-menu--btn').scrollIntoView({block: 'center'})")
  await page.click('.poll-created .action-menu--btn')
  await page.click('.v-overlay--active .action-dock__button--uncast_stance')
  await page.expectText('.confirm-modal', 'Remove your vote?')
  await page.click('.confirm-modal__submit')
  await page.expectFlash('Vote removed')
});

test('can_send_a_calendar_invite', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_closed&poll_type=meeting')
  await page.execute("document.querySelector('.poll-common-set-outcome-panel__submit').scrollIntoView({block: 'center'})")
  await page.click('.poll-common-set-outcome-panel__submit')

  await page.fillIn('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]', 'Here is a statement')
  await page.fillIn('.poll-common-calendar-invite__summary input', 'This is a meeting title')
  await page.fillIn('.poll-common-calendar-invite__location input', '123 Any St, USA')

  await page.click('.poll-common-outcome-form__submit')
  await page.expectFlash('Outcome created')
  // page.click('.dismiss-modal-button')
  // page.expectText('.poll-common-outcome-panel .lmo-markdown-wrapper', 'Here is a statement')
});

test('can_invite_non_member_to_anonymous_proposal_in_a_group', async ({ lmo: page }) => {
  await page.loadPathNoApp('polls/test_poll_scenario.email?poll_type=proposal&scenario=poll_created&anonymous=1&guest=1')
  await page.click('main h1 a')
  await page.pause(1000)
  await page.click('.poll-common-vote-form__button-text')
  await page.fillIn('.html-editor__textarea .ProseMirror', "reason")
  await page.click('.poll-common-vote-form__submit')
  await page.expectFlash('Vote created')
  // page.click('.dismiss-modal-button')
});

test('can_start_a_specified_voters_only_proposal', async ({ lmo: page }) => {
  await page.loadPath('polls/test_discussion')
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
  await page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  await page.click('.poll-common-settings__specified-voters-only .v-selection-control__wrapper')
  await page.click('.poll-common-form__submit')

  await page.expectElement('.poll-members-form')
  await page.expectText('.poll-members-form .help-link', 'Help')
  await page.expectNoElement('.poll-members-form__submit');
  await page.expectNoElement('.poll-members-form .v-checkbox');
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'test@example.com')
  await page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.expectText('.poll-members-form .help-link', 'Help')
  await page.expectNoElement('.recipients-autocomplete__no-data');
  await page.expectNoElement('.poll-members-form__list');
  await page.expectNoElement('.poll-members-form__page-count');
  await page.escape()
  await page.expectElement('.poll-members-form .v-checkbox')
  await page.expectElement('.poll-members-form .v-textarea')
  await page.expectElement('.recipients-autocomplete .v-input__details .common-notifications-count')
  await page.expectText('.poll-members-form .v-checkbox', 'Send notifications')
  const inOrder = await page.execute(() => {
    const form = document.querySelector('.poll-members-form')
    const message = form.querySelector('.v-textarea')
    const checkbox = form.querySelector('.v-checkbox')
    const submit = form.querySelector('.poll-members-form__submit')
    return Boolean(message && checkbox && submit && checkbox.parentElement === submit.parentElement &&
      message.compareDocumentPosition(checkbox) & Node.DOCUMENT_POSITION_FOLLOWING &&
      checkbox.compareDocumentPosition(submit) & Node.DOCUMENT_POSITION_FOLLOWING)
  })
  expect(inOrder, 'message, notification choice, and Invite appear in order').toBe(true)
  const messageGap = await page.execute(() => {
    const form = document.querySelector('.poll-members-form')
    return form.querySelector('.v-checkbox').parentElement.getBoundingClientRect().top - form.querySelector('.v-textarea').getBoundingClientRect().bottom
  })
  await page.click('.poll-members-form .v-checkbox .v-selection-control__wrapper')
  await page.expectNoElement('.poll-members-form .v-textarea');
  await page.expectText('.poll-members-form .v-alert', 'Voters will not be notified. Let them know about the poll another way.')
  await page.expectElement('.poll-members-form .v-alert__prepend .v-icon')
  await page.expectText('.poll-members-form__submit', 'Add voters')
  const noticeGap = await page.execute(() => {
    const form = document.querySelector('.poll-members-form')
    return form.querySelector('.v-checkbox').parentElement.getBoundingClientRect().top - form.querySelector('.v-alert').getBoundingClientRect().bottom
  })
  expect(Math.abs(noticeGap - messageGap) <= 1, 'controls have the same spacing after the message and notice').toBe(true)
  await page.click('.poll-members-form .v-checkbox .v-selection-control__wrapper')
  await page.expectElement('.poll-members-form .v-textarea')
  // page.expectElement('.text-h5')
  await page.click('.poll-members-form__submit')
  await page.expectText('.poll-members-form__list', 'test@example.com')
  await page.click('.dismiss-modal-button')
  await page.refreshAndWait()

  await page.expectText('.poll-common-card__title', 'A new proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')
  await page.expectText('.poll-common-unable-to-vote', 'You have not been invited to vote')
});

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

test('can_create_a_scheduled_proposal', async ({ lmo: page }) => {
  await page.loadPath('polls/test_discussion')
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal')
  await page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
  await page.fillIn('.poll-common-form-fields__title input', 'A scheduled proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')

  // Uncheck "opens immediately" to schedule the poll for the future
  await page.click('.poll-common-form__opens-immediately .v-selection-control__wrapper')
  await page.pause(500)

  await page.click('.poll-common-form__submit')
  await page.expectNoElement('.poll-common-form__submit', 8000)
  await page.refreshAndWait()

  // Poll should show scheduled voting info (not "Closing in...")
  await page.expectText('.poll-common-action-panel__scheduled', 'opens for voting')

  // Vote form should show as a non-interactive preview
  await page.expectElement('.poll-common-vote-form--preview')
  // Verify the poll options are visible
  await page.expectElement('.poll-common-vote-form__button')
});

test('can_view_scheduled_poll_and_add_voters', async ({ lmo: page }) => {
  await page.loadPath('polls/test_scheduled_poll')
  await page.pause(500)

  // Verify the poll shows scheduled voting info
  await page.expectText('.poll-common-action-panel__scheduled', 'opens for voting')

  // Vote form should show as a non-interactive preview with options visible
  await page.expectElement('.poll-common-vote-form--preview')
  await page.expectElement('.poll-common-vote-form__button')

  // Open the voter management window
  await page.click('.action-dock__button--announce_poll')
  await page.pause(500)

  // Verify the voter management window is shown
  await page.expectElement('.poll-members-form')

  await page.expectNoElement('.poll-members-form__submit');
  await page.expectNoElement('.poll-members-form .v-checkbox');
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'test@example.com')
  await page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.expectNoElement('.recipients-autocomplete__no-data');
  await page.expectText('.poll-members-form .help-link', 'Help')
  await page.escape()

  // Selecting a recipient reveals the submission controls.
  await page.expectText('.poll-members-form__submit', 'Add voters')
  await page.expectElement('.poll-members-form__submit')
});

test('counts_audience_recipients_before_expanding_them', async ({ lmo: page }) => {
  await page.loadPath('polls/test_scheduled_poll')
  await page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form')
  await page.click('.recipients-autocomplete input[type="text"]')
  await page.waitFor('.recipients-autocomplete-suggestion')
  await page.expectNoText('.v-overlay--active .v-list:has(.recipients-autocomplete-suggestion)', 'Everyone in the thread')
  await page.click('.recipients-autocomplete-suggestion')
  await page.expectText('.common-notifications-count', 'people will be added')
  const countText = (await page.text('.common-notifications-count')).match(/\d+ people/)[0]
  await page.expectNoElement('.poll-members-form__list');
  await page.click('.recipients-autocomplete .chip--select-multi')
  await page.waitFor('.recipients-autocomplete .chip--select-multi [class*=user-avatar]')
  expect((await page.text('.common-notifications-count')).startsWith(countText), 'expanding the audience keeps the count').toBe(true)
  await page.click('.recipients-autocomplete .v-field__clearable')
  await page.expectElement('.poll-members-form__list')
  await page.expectNoElement('.poll-members-form__submit');
});

test('can_page_and_search_poll_voters', async ({ lmo: page }) => {
  await page.loadPath('polls/test_scheduled_poll?vote_count=25&weighted=1')
  await page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form__list')
  await page.expectText('.poll-members-form', 'Manage voters')
  await page.expectText('.poll-members-form .help-link', 'Help')
  await page.expectText('.poll-members-form__page-count', '1–25 of 25')
  await page.expectElement('.poll-members-form__weight')
  await page.click('.poll-members-form__weight')
  await page.fillInAndEnter('.poll-members-form__weight-input input', '2')
  await page.expectFlash('Vote weights updated')
  await page.expectNoElement('.poll-members-form__weight-input');
  await page.expectText('.poll-members-form__weight', '2')
  await page.click('.poll-members-form__set-all')
  await page.expectText('.poll-members-form__set-all-dialog', 'Set all vote weights')
  await page.expectText('.poll-members-form__set-all-dialog', "Set each member's default vote weight")
  await page.expectText('.poll-members-form__set-all-dialog', 'Set all vote weights the same')
  await page.click('.poll-members-form__set-all-cancel')
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'No matching voter')
  await page.expectText('.poll-members-form__page-count', '0–0 of 0')
  await page.click('.poll-members-form__set-all')
  await page.expectText('.poll-members-form__set-all-search-note', 'including those outside your search results')
  await page.click('.poll-members-form__set-all-cancel')
  await page.expectNoElement('.recipients-autocomplete__no-data');
  await page.click('.poll-members-form__page-count')
  await page.expectValue('.recipients-autocomplete input[type="text"]', 'No matching voter')
  await page.expectText('.poll-members-form__page-count', '0–0 of 0')
  await page.click('.recipients-autocomplete .v-field__clearable')
  await page.expectValue('.recipients-autocomplete input[type="text"]', '')
  await page.expectNoElement('.poll-members-form__search');
  await page.expectNoElement('.poll-members-form__search-toggle');
  await page.expectText('.poll-members-form__page-count', '1–25 of 25')
});

test('confirms_removing_a_poll_voter', async ({ lmo: page }) => {
  await page.loadPath('polls/test_scheduled_poll?vote_count=4')
  await page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form__list')
  await page.expectText('.poll-members-form__page-count', '1–4 of 4')
  await page.click('.poll-members-form__remove')
  await page.expectText('.poll-members-form__remove-dialog', 'Remove')
  await page.expectText('.poll-members-form__remove-dialog', 'This also removes any vote they cast.')
  await page.click('.poll-members-form__cancel-remove')
  await page.expectText('.poll-members-form__page-count', '1–4 of 4')
  await page.click('.poll-members-form__remove')
  await page.click('.poll-members-form__confirm-remove')
  await page.expectText('.poll-members-form__page-count', '1–3 of 3')
});

test('keeps_fifty_weighted_voters_inside_the_modal', async ({ lmo: page }) => {
  await page.loadPath('polls/test_many_weighted_voters')
  await page.expectText('.poll-common-chart-panel__variable-vote-weights', 'Votes in this poll have different weights, so some count more than others.')
  await page.expectElement('.poll-common-chart-table .v-avatar-group')
  await page.expectText('.poll-common-chart-table tbody tr:last-child .v-avatar-group__overflow', '+33')
  await page.expectText('.poll-common-chart-table tbody tr:last-child td:nth-child(3)', '70')
  await page.expectCount('.poll-common-chart-table .poll-proposal-chart path', 4)
  await page.click('.poll-common-chart-table thead th:nth-child(4) button')
  await page.expectCount('.poll-common-chart-table .poll-proposal-chart path', 5)
  await page.expectElement('.poll-common-chart-table .poll-proposal-chart path[fill="#BBBBBB"]')
  await page.click('.poll-common-chart-table thead th:nth-child(6) button')
  await page.expectCount('.poll-common-chart-table .poll-proposal-chart path', 4)
  await page.expectNoElement('.poll-common-chart-table .poll-proposal-chart path[fill="#BBBBBB"]')
  await page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form__list')
  await page.expectText('.poll-members-form__page-count', '1–50 of 50')
  await page.expectText('.poll-members-form__list .v-list-item:first-child', 'Voter 45')
  await page.expectElement('.poll-members-form__weight')
  const value = await page.execute(() => {
    const modal = document.querySelector('.poll-members-form')
    const list = document.querySelector('.poll-members-form__list')
    const weights = Array.from(document.querySelectorAll('.poll-members-form__weight'), button => button.textContent.trim())
    return {modalHeight: modal.getBoundingClientRect().height, viewportHeight: window.innerHeight, listScrolls: list.scrollHeight > list.clientHeight, distinctWeights: new Set(weights).size}
  })
  expect(value.modalHeight <= value.viewportHeight * 0.9 + 1, 'modal fits within 90% of the viewport').toBe(true)
  expect(value.listScrolls, 'voter list scrolls within the modal').toBe(true)
  expect(value.distinctWeights > 1, 'voters have different vote weights').toBe(true)
});

test('pages_weighted_voters_after_fifty', async ({ lmo: page }) => {
  await page.loadPath('polls/test_many_weighted_voters?vote_count=55')
  await page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form__list')
  await page.expectText('.poll-members-form__page-count', '1–50 of 55')
  await page.expectText('.poll-members-form__list .v-list-item:first-child', 'Voter 50')
  await page.click('.poll-members-form__pagination .v-pagination__next button')
  await page.expectText('.poll-members-form__page-count', '51–55 of 55')
});

test('can_start_a_standalone_poll', async ({ lmo: page }) => {
  await page.loadPath('polls/start_poll')
  await page.expectElement('.poll-common-choose-template')
  await page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input')
  await page.fillIn('.poll-common-form-fields__title input', 'A standalone proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  await page.click('.poll-common-form__submit')
  await page.expectText('.context-panel__heading', 'A standalone proposal')
  await page.expectText('.poll-common-details-panel__details p', 'Some details')
});

test('can_open_vote_weight_settings_in_poll_form', async ({ lmo: page }) => {
  await page.loadPath('polls/start_poll?weighted=1')
  await page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form__more-settings')
  await page.click('.poll-common-form__more-settings')
  await page.expectElement('.poll-settings-weighted-voting')
  await page.expectElement('.poll-common-form__anonymous-voting-title ~ .poll-common-form__weighted-voting-title')
  await page.expectElement('.poll-common-form__weighted-voting-title ~ .poll-common-form__quorum-title')
  await page.expectText('.poll-common-form__quorum', 'Quorum')
  await page.expectText('.poll-common-form__quorum-title + .text-body-medium', 'What percentage of voters must participate')
  await page.expectAttribute('.poll-common-form__quorum input', 'placeholder', 'Percentage of eligible voters (0–100)', { exact: true });
  await page.expectElement('a[href$="/docs/en/user_manual/polls/quorum"]')
  await page.expectText('.poll-common-form', 'Give voters different vote weights. Results show both the plain and the weighted totals.')
  await page.expectElement('a[href$="/docs/en/user_manual/polls/weighted_voting"]')
  await page.expectElement('a[href$="/docs/en/user_manual/polls/anonymous_voting"]')
  await page.expectElement('a[href$="/docs/en/user_manual/polls/settings#reminder"]')
  await page.expectElement('a[href$="/docs/en/user_manual/polls/settings#vote-reason"]')
  await page.expectElement('a[href$="/docs/en/user_manual/polls/settings#hide-results"]')
  await page.expectElement('a[href$="/docs/en/user_manual/polls/settings#duration"]')
  await page.expectText('a[href$="/docs/en/user_manual/polls/weighted_voting"]', 'Read more')
  await page.expectElement('a[href$="/docs/en/user_manual/polls/weighted_voting"] .v-icon')
  await page.expectElement('a[href$="/docs/en/user_manual/polls/anonymous_voting"] .v-icon')
  await page.click('.poll-settings-weighted-voting input')
  await page.waitForPresent('.poll-settings-weighted-voting input:checked');
  await page.expectText('.poll-common-form__quorum', 'Quorum')
  await page.expectText('.poll-common-form__quorum-title + .text-body-medium', 'What percentage of eligible vote weight must participate')
  await page.expectAttribute('.poll-common-form__quorum input', 'placeholder', 'Percentage of eligible vote weight (0–100)', { exact: true });
  await page.fillIn('.poll-common-form__quorum input', '60')
  await page.click('.poll-settings-weighted-voting input')
  await page.expectText('.poll-common-form__quorum', 'Quorum')
  await page.expectText('.poll-common-form__quorum-title + .text-body-medium', 'What percentage of voters must participate')
  await page.expectAttribute('.poll-common-form__quorum input', 'placeholder', 'Percentage of eligible voters (0–100)', { exact: true });
  await expect(page.first('.poll-common-form__quorum input')).toHaveValue('60')
  await page.click('.poll-settings-weighted-voting input')
  await page.click('.poll-settings-anonymous .v-selection-control__wrapper')
  await page.waitForPresent('.poll-settings-weighted-voting input:disabled');
  await page.expectNoElement('.poll-settings-weighted-voting input:checked');
  await page.expectText('.poll-common-form__quorum', 'Quorum')
});

test('explains_that_anonymous_voting_disables_weighted_voting', async ({ lmo: page }) => {
  await page.loadPath('polls/start_poll')
  await page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form__more-settings')
  await page.click('.poll-common-form__more-settings')
  await page.click('.poll-settings-weighted-voting input')
  await page.click('.poll-settings-anonymous .v-selection-control__wrapper')
  await page.waitForPresent('.poll-settings-weighted-voting input:disabled');
  await page.expectNoElement('.poll-settings-weighted-voting input:checked');
  await page.expectText('.poll-common-form', 'Weighted voting is not available with anonymous voting')
});

test('warns_when_vote_weights_change_on_an_open_poll', async ({ lmo: page }) => {
  await page.loadPath('polls/edit_open_poll_vote_weights')
  await page.click('.poll-common-form__more-settings')
  await page.waitFor('.poll-settings-weighted-voting')
  await page.click('.poll-settings-weighted-voting input')
  await page.expectText('.poll-common-form', 'Vote weights already issued will change.')
  await page.expectText('.poll-common-form', "Turning on weighted voting copies each member's default vote weight.")
});

test('warns_when_vote_weights_are_disabled_on_an_open_poll', async ({ lmo: page }) => {
  await page.loadPath('polls/edit_open_poll_vote_weights?weighted=1')
  await page.click('.poll-common-form__more-settings')
  await page.waitFor('.poll-settings-weighted-voting')
  await page.click('.poll-settings-weighted-voting input')
  await page.expectText('.poll-common-form', 'Vote weights already issued will change.')
  await page.expectText('.poll-common-form', 'Turning off weighted voting sets every vote weight to 1')
});
