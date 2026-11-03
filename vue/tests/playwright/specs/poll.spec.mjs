import { test, expect } from '../fixtures.mjs';


test('identified_vote_form_disappears_after_voting_without_a_reason', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_created&poll_type=proposal')
  await page.locator('.poll-common-vote-form__button-text').click()
  await page.locator('.poll-common-vote-form__submit').click()
  await expect(page.locator('.poll-common-vote-form')).toHaveCount(0)
  await expect(page.locator('.poll-common-current-vote')).toBeVisible()
});

test('can_start_a_proposal_in_a_group', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.decision-tools-card__poll-type--proposal').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')
  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()
  await expect(page.locator('.poll-common-card__title')).toContainText('A new proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')

  await page.locator('.poll-common-vote-form__button-text').click()
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').fill('A reason')
  await page.locator('.poll-common-vote-form__submit').click()
  await expect(page.locator('.poll-common-stance-created__reason')).toContainText('A reason')
  await expect(page.locator('.poll-created .poll-common-chart-panel ~ .poll-common-action-panel .poll-common-current-vote')).toBeVisible()
});

test('can_start_a_poll_in_a_group', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.poll-common-choose-template__poll').click()
  await page.locator('.decision-tools-card__poll-type--poll').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')

  await page.locator('.poll-common-form__add-option-btn').click()
  await page.locator('.poll-option-form__name input').fill('An option')
  await page.locator('.poll-option-form__done-btn').click()

  await page.locator('.poll-common-form__add-option-btn').click()
  await page.locator('.poll-option-form__name input').fill('Another option')
  await page.locator('.poll-option-form__done-btn').click()

  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()

  await expect(page.locator('.poll-common-card__title')).toContainText('A new proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')
  await page.locator('.poll-common-vote-form__button-text').click()
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').fill('A reason')
  await page.locator('.poll-common-vote-form__submit').click()
  await expect(page.locator('.poll-common-stance-choice')).toContainText('An option')
  await expect(page.locator('.poll-common-stance-created__reason')).toContainText('A reason')
});

test('shows_none_of_the_above_as_the_current_vote', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_none_of_the_above')
  await expect(page.locator('.poll-common-current-vote')).toContainText('None of the above')
});

test('can_start_a_dot_vote_in_a_group', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.poll-common-choose-template__poll').click()
  await page.locator('.decision-tools-card__poll-type--dot_vote').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')

  await page.locator('.poll-common-form__add-option-btn').click()
  await page.locator('.poll-option-form__name input').fill('An option')
  await page.locator('.poll-option-form__done-btn').click()

  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()

  await expect(page.locator('.poll-common-card__title')).toContainText('A new proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')

  await page.locator('.poll-dot-vote-vote-form__option .v-slider').click()
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').fill('A reason')
  await page.locator('.poll-common-vote-form__submit').click()

  await expect(page.locator('.poll-common-stance-choice--dot_vote')).toContainText('An option')
  await expect(page.locator('.poll-common-stance-created__reason')).toContainText('A reason')
});

test('can_start_a_score_poll_in_a_group', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.poll-common-choose-template__poll').click()
  await page.locator('.decision-tools-card__poll-type--score').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')

  await page.locator('.poll-common-form__add-option-btn').click()
  await page.locator('.poll-option-form__name input').fill('An option')
  await page.locator('.poll-option-form__done-btn').click()

  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()

  await expect(page.locator('.poll-common-card__title')).toContainText('A new proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')

  await page.locator('.vote-form-number-input').fill(1)
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').fill('A reason')
  await page.locator('.poll-common-vote-form__submit').click()

  await expect(page.locator('.poll-common-stance-choice--score')).toContainText('An option')
  await expect(page.locator('.poll-common-stance-created__reason')).toContainText('A reason')
});

test('can_start_a_time_poll_in_a_group', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion?time_zone=America%2FLos_Angeles')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.poll-common-choose-template__poll').click()
  await page.locator('.decision-tools-card__poll-type--meeting').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')
  await expect(page.locator('.date-time-picker')).toContainText('America/Los_Angeles')
  await page.locator('.date-time-picker__time-field input[role="combobox"]').fill('07:30')
  await expect(page.locator('.date-time-picker')).toContainText('7:30 AM')
  await page.locator('.poll-meeting-form__option-button').click()
  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()

  await expect(page.locator('.poll-common-card__title')).toContainText('A new proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')
  await expect(page.locator('.poll-meeting-time')).toContainText('7:30AM')

  await page.locator('.poll-meeting-vote-form--box').click()
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').fill('A reason')
  await page.locator('.poll-common-vote-form__submit').click()

  await expect(page.locator('.poll-common-stance-created__reason')).toContainText('A reason')
});

// Skipped because it failed too often under Nightwatch; re-enable once it is stable.
test.skip('can_start_a_ranked_choice_in_a_group', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator(".poll-common-choose-template__poll").click()
  await page.locator('.decision-tools-card__poll-type--ranked_choice').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')

  await page.locator('.poll-common-form__add-option-btn').click()
  await page.locator('.poll-option-form__name input').fill('An option')
  await page.locator('.poll-option-form__done-btn').click()

  await page.locator('.poll-common-form__add-option-btn').click()
  await page.locator('.poll-option-form__name input').fill('Another option')
  await page.locator('.poll-option-form__done-btn').click()

  await page.locator('.poll-common-form__submit').click()

  await expect(page.locator('.poll-common-card__title')).toContainText('A new proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').fill('A reason')
  await page.locator('.poll-common-vote-form__submit').click()
  await expect(page.locator('.poll-common-stance-choice--ranked_choice:first-child')).toContainText('An option')
  await expect(page.locator('.poll-common-stance-created__reason')).toContainText('A reason')
});

test('can_set_an_outcome', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal')
  await page.locator('.poll-common-set-outcome-panel__submit').click()

  await page.locator('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]').fill('This is an outcome')
  await page.locator('.poll-common-outcome-form__submit').click()

  await expect(page.locator('.poll-common-outcome-panel')).toContainText('This is an outcome')
});

test('opens_reminder_form_after_reopening_a_poll', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal')
  await page.locator('.poll-created .action-menu--btn:visible').click()
  await expect(page.locator('.action-dock__button--reopen_poll')).toBeVisible()
  await page.locator('.action-dock__button--reopen_poll:visible').click()
  await page.locator('.poll-common-reopen-form__submit').click()
  await expect(page.locator('.poll-remind')).toContainText('Remind to vote')
});

test('can_start_an_anonymous_poll', async ({ page }) => {
  await page.goto('/dev//polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.decision-tools-card__poll-type--proposal').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')
  await page.locator('.poll-common-form__more-settings').click()
  await expect(page.locator('.poll-common-form__anonymous-voting-explanation')).toContainText('Anonymous votes are stored separately from voter identities. Results only appear after voting closes, and voters cannot add reasons, review their vote after submitting it, or change it.')
  await expect(page.locator('.poll-common-form__anonymous-voting-title ~ .poll-common-form__weighted-voting-title')).toBeVisible()
  await expect(page.locator('.poll-common-form__weighted-voting-title ~ .poll-common-form__quorum-title')).toBeVisible()
  await expect(page.locator('.poll-common-form__quorum-title ~ .poll-common-form__reminder-title')).toBeVisible()
  await page.locator('.poll-settings-anonymous .v-selection-control__wrapper').click()
  await expect(page.locator('.poll-common-settings__notify-on-closing-soon')).toContainText("People who haven't voted")
  await expect(page.locator('.poll-common-settings__notify-on-closing-soon.v-input--disabled')).toBeVisible()
  await expect(page.locator('.poll-common-settings__hide-results')).toContainText('Until voting is closed')
  await expect(page.locator('.poll-common-settings__hide-results.v-input--disabled')).toBeVisible()
  await expect(page.locator('.poll-common-form__stance-reason-required')).toContainText('Disabled')
  await expect(page.locator('.poll-common-form__stance-reason-required.v-input--disabled')).toBeVisible()

  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()

  await expect(page.locator('.poll-common-card__title')).toContainText('A new proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')
  await expect(page.locator('.poll-common-action-panel__anonymous-message')).toContainText('Voting is anonymous. You cannot review or change your vote after submitting it. Results are not available until voting has closed.')
  await expect(page.locator('.poll-common-action-panel__results-hidden-until-closed')).toHaveCount(0)

  await page.locator('.poll-common-vote-form__button-text').click()
  await page.locator('.poll-common-vote-form__submit').click()
  await expect(page.locator('.poll-common-action-panel__recorded')).toContainText('Your vote was recorded')
  await expect(page.locator('.poll-common-action-panel__anonymous-message')).toContainText('Voting is anonymous. You cannot review or change your vote after submitting it. Results are not available until voting has closed.')
  await expect(page.locator('.poll-common-vote-form')).toHaveCount(0)
  await expect(page.locator('.poll-common-action-panel__results-hidden-until-closed')).toHaveCount(0)
  await expect(page.locator('.action-dock__button--view_votes')).toHaveCount(0)

  await page.locator('.action-dock__button--close_poll').click()
  await page.locator('.confirm-modal__submit').click()
  await expect(page.locator('.poll-common-action-panel__anonymous-closed-message')).toContainText('Votes are anonymous')
  await expect(page.locator('.action-dock__button--view_votes')).toBeVisible()
  await expect(page.locator('.confirm-modal')).toHaveCount(0)

  await page.locator('.poll-common-set-outcome-panel__submit').click()
  await page.locator('.recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.v-autocomplete__content')).toContainText('Everyone invited to vote')
  await expect(page.locator('.v-autocomplete__content')).not.toContainText('Everyone who voted')
  await expect(page.locator('.v-autocomplete__content')).not.toContainText("People who haven't voted")
});

test('shows_migrated_legacy_anonymous_participation_without_vote_reasons', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_legacy_anonymous&poll_type=proposal')
  await page.locator('.action-dock__button--view_votes').click()
  await expect(page.locator('.poll-common-votes-panel table')).toBeVisible()
  await expect(page.locator('.poll-common-votes-panel')).not.toContainText('A plain text reason retained from the legacy vote')
});

test('shows_identified_votes_in_a_table', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal')
  await page.locator('.action-dock__button--view_votes').click()
  await expect(page.locator('.v-container--fluid .votes-page')).toBeVisible()
  await expect(page.locator('.topic-header h1')).toContainText('Votes')
  await expect(page.locator('.topic-header .v-breadcrumbs')).not.toContainText('Votes')
  await expect(page.locator('.poll-common-votes-panel table thead')).toContainText('Name')
  await expect(page.locator('.poll-common-votes-panel table thead')).toContainText('Vote')
  await expect(page.locator('.poll-common-votes-panel table thead')).not.toContainText('Voted on')
});

test('can_start_a_results_hidden_until_closed_poll', async ({ page }) => {
  await page.goto('/dev//polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.decision-tools-card__poll-type--proposal').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')
  // Wait for More settings to finish expanding, so the field stays put while it is clicked.
  await page.locator('.poll-common-form__more-settings').click()
  await expect(page.locator('.expand-transition-enter-active')).toHaveCount(0)
  await page.locator('.poll-common-settings__hide-results .v-field').click()
  await expect(page.locator('.v-overlay--active .v-list-item')).toBeVisible()
  await page.locator('.v-overlay--active .v-list-item').last().click()


  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()

  await expect(page.locator('.poll-common-card__title')).toContainText('A new proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')
  await expect(page.locator('.poll-common-action-panel__results-hidden-until-closed')).toBeVisible()
});

test('can_remove_own_vote', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?poll_type=proposal&scenario=poll_closing_soon_with_vote')
  // The thread header has its own action menu, so target the poll's.
  await page.locator('.poll-created .action-menu--btn').click()
  await page.locator('.v-overlay--active .action-dock__button--uncast_stance').click()
  await expect(page.locator('.confirm-modal')).toContainText('Remove your vote?')
  await page.locator('.confirm-modal__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Vote removed')
});

test('can_send_a_calendar_invite', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_closed&poll_type=meeting')
  await page.locator('.poll-common-set-outcome-panel__submit').click()

  await page.locator('.poll-common-outcome-form__statement .lmo-textarea div[contenteditable=true]').fill('Here is a statement')
  await page.locator('.poll-common-calendar-invite__summary input').fill('This is a meeting title')
  await page.locator('.poll-common-calendar-invite__location input').fill('123 Any St, USA')

  await page.locator('.poll-common-outcome-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Outcome created')
});

test('can_invite_non_member_to_anonymous_proposal_in_a_group', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario.email?poll_type=proposal&scenario=poll_created&anonymous=1&guest=1')
  await page.locator('main h1 a').click()
  await page.locator('.poll-common-vote-form__button-text').click()
  await page.locator('.html-editor__textarea .ProseMirror').fill("reason")
  await page.locator('.poll-common-vote-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Vote created')
});

test('can_start_a_specified_voters_only_proposal', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.decision-tools-card__poll-type--proposal').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')
  await page.locator('.poll-common-settings__specified-voters-only .v-selection-control__wrapper').click()
  await page.locator('.poll-common-form__submit').click()

  await expect(page.locator('.poll-members-form')).toBeVisible()
  await expect(page.locator('.poll-members-form .help-link')).toContainText('Help')
  await expect(page.locator('.poll-members-form__submit')).toHaveCount(0)
  await expect(page.locator('.poll-members-form .v-checkbox')).toHaveCount(0)
  await page.locator('.recipients-autocomplete input[type="text"]').pressSequentially('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.locator('.recipients-autocomplete-suggestion').click()
  await expect(page.locator('.poll-members-form .help-link')).toContainText('Help')
  await expect(page.locator('.recipients-autocomplete__no-data')).toHaveCount(0)
  await expect(page.locator('.poll-members-form__list')).toHaveCount(0)
  await expect(page.locator('.poll-members-form__page-count')).toHaveCount(0)
  await page.keyboard.press('Escape')
  await expect(page.locator('.poll-members-form .v-checkbox')).toBeVisible()
  await expect(page.locator('.poll-members-form .v-textarea')).toBeVisible()
  await expect(page.locator('.recipients-autocomplete .v-input__details .common-notifications-count')).toBeVisible()
  await expect(page.locator('.poll-members-form .v-checkbox')).toContainText('Send notifications')
  const inOrder = await page.evaluate(() => {
    const form = document.querySelector('.poll-members-form')
    const message = form.querySelector('.v-textarea')
    const checkbox = form.querySelector('.v-checkbox')
    const submit = form.querySelector('.poll-members-form__submit')
    return Boolean(message && checkbox && submit && checkbox.parentElement === submit.parentElement &&
      message.compareDocumentPosition(checkbox) & Node.DOCUMENT_POSITION_FOLLOWING &&
      checkbox.compareDocumentPosition(submit) & Node.DOCUMENT_POSITION_FOLLOWING)
  })
  expect(inOrder, 'message, notification choice, and Invite appear in order').toBe(true)
  const messageGap = await page.evaluate(() => {
    const form = document.querySelector('.poll-members-form')
    return form.querySelector('.v-checkbox').parentElement.getBoundingClientRect().top - form.querySelector('.v-textarea').getBoundingClientRect().bottom
  })
  await page.locator('.poll-members-form .v-checkbox .v-selection-control__wrapper').click()
  await expect(page.locator('.poll-members-form .v-textarea')).toHaveCount(0)
  await expect(page.locator('.poll-members-form .v-alert')).toContainText('Voters will not be notified. Let them know about the poll another way.')
  await expect(page.locator('.poll-members-form .v-alert__prepend .v-icon')).toBeVisible()
  await expect(page.locator('.poll-members-form__submit')).toContainText('Add voters')
  const noticeGap = await page.evaluate(() => {
    const form = document.querySelector('.poll-members-form')
    return form.querySelector('.v-checkbox').parentElement.getBoundingClientRect().top - form.querySelector('.v-alert').getBoundingClientRect().bottom
  })
  expect(Math.abs(noticeGap - messageGap) <= 1, 'controls have the same spacing after the message and notice').toBe(true)
  await page.locator('.poll-members-form .v-checkbox .v-selection-control__wrapper').click()
  await expect(page.locator('.poll-members-form .v-textarea')).toBeVisible()
  await page.locator('.poll-members-form__submit').click()
  await expect(page.locator('.poll-members-form__list')).toContainText('test@example.com')
  await page.locator('.dismiss-modal-button').click()
  await page.reload()

  await expect(page.locator('.poll-common-card__title')).toContainText('A new proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')
  await expect(page.locator('.poll-common-unable-to-vote')).toContainText('You have not been invited to vote')
});

test('can_create_a_scheduled_proposal', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.decision-tools-card__poll-type--proposal').click()
  await page.locator('.poll-common-form-fields__title input').fill('A scheduled proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')

  // Uncheck "opens immediately" to schedule the poll for the future
  await page.locator('.poll-common-form__opens-immediately .v-selection-control__wrapper').click()

  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()

  // Poll should show scheduled voting info (not "Closing in...")
  await expect(page.locator('.poll-common-action-panel__scheduled')).toContainText('opens for voting')

  // Vote form should show as a non-interactive preview
  await expect(page.locator('.poll-common-vote-form--preview')).toBeVisible()
  // Verify the poll options are visible
  await expect(page.locator('.poll-common-vote-form__button')).toBeVisible()
});

test('can_view_scheduled_poll_and_add_voters', async ({ page }) => {
  await page.goto('/dev/polls/test_scheduled_poll')

  // Verify the poll shows scheduled voting info
  await expect(page.locator('.poll-common-action-panel__scheduled')).toContainText('opens for voting')

  // Vote form should show as a non-interactive preview with options visible
  await expect(page.locator('.poll-common-vote-form--preview')).toBeVisible()
  await expect(page.locator('.poll-common-vote-form__button')).toBeVisible()

  // Open the voter management window
  await page.locator('.action-dock__button--announce_poll').click()

  // Verify the voter management window is shown
  await expect(page.locator('.poll-members-form')).toBeVisible()

  await expect(page.locator('.poll-members-form__submit')).toHaveCount(0)
  await expect(page.locator('.poll-members-form .v-checkbox')).toHaveCount(0)
  await page.locator('.recipients-autocomplete input[type="text"]').pressSequentially('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.locator('.recipients-autocomplete-suggestion').click()
  await expect(page.locator('.recipients-autocomplete__no-data')).toHaveCount(0)
  await expect(page.locator('.poll-members-form .help-link')).toContainText('Help')
  await page.keyboard.press('Escape')

  // Selecting a recipient reveals the submission controls.
  await expect(page.locator('.poll-members-form__submit')).toContainText('Add voters')
  await expect(page.locator('.poll-members-form__submit')).toBeVisible()
});

test('counts_audience_recipients_before_expanding_them', async ({ page }) => {
  await page.goto('/dev/polls/test_scheduled_poll')
  await page.locator('.action-dock__button--announce_poll').click()
  await page.locator('.recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.recipients-autocomplete-suggestion')).toBeVisible()
  await expect(page.locator('.v-overlay--active .v-list:has(.recipients-autocomplete-suggestion)')).not.toContainText('Everyone in the thread')
  await page.locator('.recipients-autocomplete-suggestion').click()
  await expect(page.locator('.common-notifications-count')).toContainText('people will be added')
  const countText = (await page.locator('.common-notifications-count').first().innerText()).match(/\d+ people/)[0]
  await expect(page.locator('.poll-members-form__list')).toHaveCount(0)
  await page.locator('.recipients-autocomplete .chip--select-multi').click()
  await expect(page.locator('.recipients-autocomplete .chip--select-multi [class*=user-avatar]')).toBeVisible()
  expect((await page.locator('.common-notifications-count').first().innerText()).startsWith(countText), 'expanding the audience keeps the count').toBe(true)
  await page.locator('.recipients-autocomplete .v-field__clearable').click()
  await expect(page.locator('.poll-members-form__list')).toBeVisible()
  await expect(page.locator('.poll-members-form__submit')).toHaveCount(0)
});

test('can_page_and_search_poll_voters', async ({ page }) => {
  await page.goto('/dev/polls/test_scheduled_poll?vote_count=25&weighted=1')
  await page.locator('.action-dock__button--announce_poll').click()
  await expect(page.locator('.poll-members-form')).toContainText('Manage voters')
  await expect(page.locator('.poll-members-form .help-link')).toContainText('Help')
  await expect(page.locator('.poll-members-form__page-count')).toContainText('1–25 of 25')
  await page.locator('.poll-members-form__weight').click()
  await page.locator('.poll-members-form__weight-input input').fill('2')
  await page.locator('.poll-members-form__weight-input input').press('Enter')
  await expect(page.locator('.flash-root__message')).toContainText('Vote weights updated')
  await expect(page.locator('.poll-members-form__weight-input')).toHaveCount(0)
  await expect(page.locator('.poll-members-form__weight')).toContainText('2')
  await page.locator('.poll-members-form__set-all').click()
  await expect(page.locator('.poll-members-form__set-all-dialog')).toContainText('Set all vote weights')
  await expect(page.locator('.poll-members-form__set-all-dialog')).toContainText("Set each member's default vote weight")
  await expect(page.locator('.poll-members-form__set-all-dialog')).toContainText('Set all vote weights the same')
  await page.locator('.poll-members-form__set-all-cancel').click()
  await page.locator('.recipients-autocomplete input[type="text"]').fill('No matching voter')
  await expect(page.locator('.poll-members-form__page-count')).toContainText('0–0 of 0')
  await page.locator('.poll-members-form__set-all').click()
  await expect(page.locator('.poll-members-form__set-all-search-note')).toContainText('including those outside your search results')
  await page.locator('.poll-members-form__set-all-cancel').click()
  await expect(page.locator('.recipients-autocomplete__no-data')).toHaveCount(0)
  await page.locator('.poll-members-form__page-count').click()
  await expect(page.locator('.recipients-autocomplete input[type="text"]')).toHaveValue('No matching voter')
  await expect(page.locator('.poll-members-form__page-count')).toContainText('0–0 of 0')
  await page.locator('.recipients-autocomplete .v-field__clearable').click()
  await expect(page.locator('.recipients-autocomplete input[type="text"]')).toHaveValue('')
  await expect(page.locator('.poll-members-form__search')).toHaveCount(0)
  await expect(page.locator('.poll-members-form__search-toggle')).toHaveCount(0)
  await expect(page.locator('.poll-members-form__page-count')).toContainText('1–25 of 25')
});

test('confirms_removing_a_poll_voter', async ({ page }) => {
  await page.goto('/dev/polls/test_scheduled_poll?vote_count=4')
  await page.locator('.action-dock__button--announce_poll').click()
  await expect(page.locator('.poll-members-form__page-count')).toContainText('1–4 of 4')
  await page.locator('.poll-members-form__remove').click()
  await expect(page.locator('.poll-members-form__remove-dialog')).toContainText('Remove')
  await expect(page.locator('.poll-members-form__remove-dialog')).toContainText('This also removes any vote they cast.')
  await page.locator('.poll-members-form__cancel-remove').click()
  await expect(page.locator('.poll-members-form__page-count')).toContainText('1–4 of 4')
  await page.locator('.poll-members-form__remove').click()
  await page.locator('.poll-members-form__confirm-remove').click()
  await expect(page.locator('.poll-members-form__page-count')).toContainText('1–3 of 3')
});

test('keeps_fifty_weighted_voters_inside_the_modal', async ({ page }) => {
  await page.goto('/dev/polls/test_many_weighted_voters')
  await expect(page.locator('.poll-common-chart-panel__variable-vote-weights')).toContainText('Votes in this poll have different weights, so some count more than others.')
  await expect(page.locator('.poll-common-chart-table .v-avatar-group')).toBeVisible()
  await expect(page.locator('.poll-common-chart-table tbody tr:last-child .v-avatar-group__overflow')).toContainText('+33')
  await expect(page.locator('.poll-common-chart-table tbody tr:last-child td:nth-child(3)')).toContainText('70')
  await expect(page.locator('.poll-common-chart-table .poll-proposal-chart path')).toHaveCount(4)
  await page.locator('.poll-common-chart-table thead th:nth-child(4) button').click()
  await expect(page.locator('.poll-common-chart-table .poll-proposal-chart path')).toHaveCount(5)
  await expect(page.locator('.poll-common-chart-table .poll-proposal-chart path[fill="#BBBBBB"]')).toBeVisible()
  await page.locator('.poll-common-chart-table thead th:nth-child(6) button').click()
  await expect(page.locator('.poll-common-chart-table .poll-proposal-chart path')).toHaveCount(4)
  await expect(page.locator('.poll-common-chart-table .poll-proposal-chart path[fill="#BBBBBB"]')).toHaveCount(0)
  await page.locator('.action-dock__button--announce_poll').click()
  await expect(page.locator('.poll-members-form__page-count')).toContainText('1–50 of 50')
  await expect(page.locator('.poll-members-form__list .v-list-item:first-child')).toContainText('Voter 45')
  await expect(page.locator('.poll-members-form__weight')).toBeVisible()
  const value = await page.evaluate(() => {
    const modal = document.querySelector('.poll-members-form')
    const list = document.querySelector('.poll-members-form__list')
    const weights = Array.from(document.querySelectorAll('.poll-members-form__weight'), button => button.textContent.trim())
    return {modalHeight: modal.getBoundingClientRect().height, viewportHeight: window.innerHeight, listScrolls: list.scrollHeight > list.clientHeight, distinctWeights: new Set(weights).size}
  })
  expect(value.modalHeight <= value.viewportHeight * 0.9 + 1, 'modal fits within 90% of the viewport').toBe(true)
  expect(value.listScrolls, 'voter list scrolls within the modal').toBe(true)
  expect(value.distinctWeights > 1, 'voters have different vote weights').toBe(true)
});

test('pages_weighted_voters_after_fifty', async ({ page }) => {
  await page.goto('/dev/polls/test_many_weighted_voters?vote_count=55')
  await page.locator('.action-dock__button--announce_poll').click()
  await expect(page.locator('.poll-members-form__page-count')).toContainText('1–50 of 55')
  await expect(page.locator('.poll-members-form__list .v-list-item:first-child')).toContainText('Voter 50')
  await page.locator('.poll-members-form__pagination .v-pagination__next button').click()
  await expect(page.locator('.poll-members-form__page-count')).toContainText('51–55 of 55')
});

test('can_start_a_standalone_poll', async ({ page }) => {
  await page.goto('/dev/polls/start_poll')
  await expect(page.locator('.poll-common-choose-template')).toBeVisible()
  await page.locator('.decision-tools-card__poll-type--proposal').click()
  await page.locator('.poll-common-form-fields__title input').fill('A standalone proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')
  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.context-panel__heading')).toContainText('A standalone proposal')
  await expect(page.locator('.poll-common-details-panel__details p')).toContainText('Some details')
});

test('can_open_vote_weight_settings_in_poll_form', async ({ page }) => {
  await page.goto('/dev/polls/start_poll?weighted=1')
  await page.locator('.decision-tools-card__poll-type--proposal').click()
  await page.locator('.poll-common-form__more-settings').click()
  await expect(page.locator('.poll-settings-weighted-voting')).toBeVisible()
  await expect(page.locator('.poll-common-form__anonymous-voting-title ~ .poll-common-form__weighted-voting-title')).toBeVisible()
  await expect(page.locator('.poll-common-form__weighted-voting-title ~ .poll-common-form__quorum-title')).toBeVisible()
  await expect(page.locator('.poll-common-form__quorum')).toContainText('Quorum')
  await expect(page.locator('.poll-common-form__quorum-title + .text-body-medium')).toContainText('What percentage of voters must participate')
  await expect(page.locator('.poll-common-form__quorum input')).toHaveAttribute('placeholder', 'Percentage of eligible voters (0–100)')
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/quorum"]')).toBeVisible()
  await expect(page.locator('.poll-common-form')).toContainText('Give voters different vote weights. Results show both the plain and the weighted totals.')
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/weighted_voting"]')).toBeVisible()
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/anonymous_voting"]')).toBeVisible()
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/settings#reminder"]')).toBeVisible()
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/settings#vote-reason"]')).toBeVisible()
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/settings#hide-results"]')).toBeVisible()
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/settings#duration"]')).toBeVisible()
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/weighted_voting"]')).toContainText('Read more')
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/weighted_voting"] .v-icon')).toBeVisible()
  await expect(page.locator('a[href$="/docs/en/user_manual/polls/anonymous_voting"] .v-icon')).toBeVisible()
  await page.locator('.poll-settings-weighted-voting input').click()
  await expect(page.locator('.poll-settings-weighted-voting input:checked')).toBeAttached()
  await expect(page.locator('.poll-common-form__quorum')).toContainText('Quorum')
  await expect(page.locator('.poll-common-form__quorum-title + .text-body-medium')).toContainText('What percentage of eligible vote weight must participate')
  await expect(page.locator('.poll-common-form__quorum input')).toHaveAttribute('placeholder', 'Percentage of eligible vote weight (0–100)')
  await page.locator('.poll-common-form__quorum input').fill('60')
  await page.locator('.poll-settings-weighted-voting input').click()
  await expect(page.locator('.poll-common-form__quorum')).toContainText('Quorum')
  await expect(page.locator('.poll-common-form__quorum-title + .text-body-medium')).toContainText('What percentage of voters must participate')
  await expect(page.locator('.poll-common-form__quorum input')).toHaveAttribute('placeholder', 'Percentage of eligible voters (0–100)')
  await expect(page.locator('.poll-common-form__quorum input').first()).toHaveValue('60')
  await page.locator('.poll-settings-weighted-voting input').click()
  await page.locator('.poll-settings-anonymous .v-selection-control__wrapper').click()
  await expect(page.locator('.poll-settings-weighted-voting input:disabled')).toBeAttached()
  await expect(page.locator('.poll-settings-weighted-voting input:checked')).toHaveCount(0)
  await expect(page.locator('.poll-common-form__quorum')).toContainText('Quorum')
});

test('explains_that_anonymous_voting_disables_weighted_voting', async ({ page }) => {
  await page.goto('/dev/polls/start_poll')
  await page.locator('.decision-tools-card__poll-type--proposal').click()
  await page.locator('.poll-common-form__more-settings').click()
  await page.locator('.poll-settings-weighted-voting input').click()
  await page.locator('.poll-settings-anonymous .v-selection-control__wrapper').click()
  await expect(page.locator('.poll-settings-weighted-voting input:disabled')).toBeAttached()
  await expect(page.locator('.poll-settings-weighted-voting input:checked')).toHaveCount(0)
  await expect(page.locator('.poll-common-form')).toContainText('Weighted voting is not available with anonymous voting')
});

test('warns_when_vote_weights_change_on_an_open_poll', async ({ page }) => {
  await page.goto('/dev/polls/edit_open_poll_vote_weights')
  await page.locator('.poll-common-form__more-settings').click()
  await expect(page.locator('.poll-settings-weighted-voting')).toBeVisible()
  await page.locator('.poll-settings-weighted-voting input').click()
  await expect(page.locator('.poll-common-form')).toContainText('Vote weights already issued will change.')
  await expect(page.locator('.poll-common-form')).toContainText("Turning on weighted voting copies each member's default vote weight.")
});

test('warns_when_vote_weights_are_disabled_on_an_open_poll', async ({ page }) => {
  await page.goto('/dev/polls/edit_open_poll_vote_weights?weighted=1')
  await page.locator('.poll-common-form__more-settings').click()
  await expect(page.locator('.poll-settings-weighted-voting')).toBeVisible()
  await page.locator('.poll-settings-weighted-voting input').click()
  await expect(page.locator('.poll-common-form')).toContainText('Vote weights already issued will change.')
  await expect(page.locator('.poll-common-form')).toContainText('Turning off weighted voting sets every vote weight to 1')
});
