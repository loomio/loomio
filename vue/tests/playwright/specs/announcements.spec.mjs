import { test, expect } from '../fixtures.mjs';

// GK: a couple of these are dependent on the poll page which we haven't done yet

test('invite_to_group', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.group-page-members-tab')
  await page.click('.membership-card__invite', 1000)
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'test@example.com')
  await page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.click('.announcement-form__submit')
  await page.expectFlash('1 notifications sent')
});

test('expand_parent_group_members_when_inviting_to_a_subgroup', async ({ lmo: page }) => {
  await page.loadPath('setup_subgroup_invitation_audiences')
  await page.click('.group-page-members-tab')
  await page.click('.membership-card__invite', 1000)
  await page.click('.recipients-autocomplete input[type="text"]')
  await page.expectText('.v-autocomplete__content', 'Point Break')
  await page.execute("Array.from(document.querySelectorAll('.recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Point Break')).click()")
  await page.click('.recipients-autocomplete .chip--select-multi')
  await page.expectText('.recipients-autocomplete', 'Max Von Sydow')
  await page.expectNoText('.recipients-autocomplete', 'Jennifer Grey')
});

test('invite_parent_group_members_to_a_subgroup_without_expanding_the_audience', async ({ lmo: page }) => {
  await page.loadPath('setup_subgroup_invitation_audiences')
  await page.click('.group-page-members-tab')
  await page.click('.membership-card__invite', 1000)
  await page.click('.recipients-autocomplete input[type="text"]')
  await page.execute("Array.from(document.querySelectorAll('.recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Point Break')).click()")
  await page.click('.announcement-form__submit')
  await page.expectFlash('1 notifications sent')
  await page.expectText('.members-panel', 'Max Von Sydow')
});

  // discussion form
test('new_discussion', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.discussions-panel__new-topic-button')
  await page.click('.discussion-templates--template')
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'test@example.com')
  await page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.fillIn('.discussion-form__title-input input', 'Immannounce dis')
  await page.click('.discussion-form__submit')
  await page.expectFlash('Discussion started')
  // page.expectElement('.announcement-form')
  // page.click('.announcement-form__audience')
  // page.click('.announcement-form__submit', 1000)
  // page.expectFlash('2 notifications sent')
});

test('new_direct_discussion_autocompletes_recipients_without_a_group', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.ensureSidebar()
  await page.click('.sidebar__list-item-button--private')
  await page.click('.topics-page__new-topic-button')
  await page.click('.discussion-templates--direct-discussion')
  await page.waitFor('.discussion-form')
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'test@example.com')
  await page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
});

  // topic members list
test('announcement_created', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.pause(500)
  await page.click('.action-dock__button--announce_thread')
  await page.expectElement('.topic-members-list')
  await page.pause(500)
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'test@example.com')
  await page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.escape()
  // page.expectElement('.text-h5')
  await page.click('.topic-members-list__submit')
  await page.expectText('.topic-members-list', 'test@example.com')
  await page.expectFlash('1 notifications sent')
});

test('announcement_autocompletes_group_member_names', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.click('.action-dock__button--announce_thread')
  await page.expectElement('.topic-members-list')
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'Emilio')
  await page.expectText('.recipients-autocomplete-suggestion', 'Emilio Estevez')
});

test('pages_and_filters_thread_members', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion_many_members')
  await page.clickAndWait('.action-dock__button--announce_thread', '.topic-members-list__readers')
  await page.expectText('.topic-members-list', 'Manage thread members')
  await page.expectText('.topic-members-list .help-link', 'Help')
  await page.expectText('.topic-members-list__page-count', '1–50 of 52')
  await page.expectText('.topic-members-list__readers', 'Thread member 50')
  await page.click('.topic-members-list__pagination .v-pagination__next button')
  await page.expectText('.topic-members-list__page-count', '51–52 of 52')
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'Thread member 50')
  await page.expectText('.topic-members-list__page-count', '1–1 of 1')
  await page.click('.topic-members-list__page-count')
  await page.expectValue('.recipients-autocomplete input[type="text"]', 'Thread member 50')
  await page.click('.recipients-autocomplete .v-field__clearable')
  await page.expectText('.topic-members-list__page-count', '1–50 of 52')
  await page.expectNoElement('.topic-members-list textarea')
  await page.expectNoElement('.topic-members-list__submit')
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'test@example.com')
  await page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.expectElement('.topic-members-list textarea')
  await page.expectElement('.topic-members-list__submit')
  await page.expectText('.topic-members-list', 'New people will be invited to the thread')
  await page.expectNoElement('.topic-members-list__readers')
  await page.click('.recipients-autocomplete .v-field__clearable')
  await page.expectElement('.topic-members-list__readers')
  await page.click('.topic-members-list .v-alert__close button')
  await page.expectNoText('.topic-members-list', 'Guests invited by email can participate')
  await page.click('.topic-members-list .dismiss-modal-button')
  await page.clickAndWait('.action-dock__button--announce_thread', '.topic-members-list__readers')
  await page.expectNoText('.topic-members-list', 'Guests invited by email can participate')
});

  // poll members list
test('poll_created', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.click('.activity-panel__add-poll')
  await page.click('.decision-tools-card__poll-type--proposal')
  await page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
  await page.fillIn('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  await page.click('.poll-common-settings__specified-voters-only label')
  await page.click('.poll-common-form__submit')
  await page.expectFlash('Proposal started')
  await page.pause(500)

  await page.expectElement('.poll-members-form')
  await page.click('.recipients-autocomplete input[type="text"]')
  await page.waitFor('.recipients-autocomplete-suggestion')
  await page.expectNoText('.v-autocomplete__content', 'Everyone in the thread')
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'test@example.com')
  await page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.escape()
  // page.expectElement('.text-h5')
  await page.click('.poll-members-form__submit')
  await page.expectFlash('1 notifications sent')
});

  // 'poll_edited': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('test_poll_in_discussion', { controller: 'polls' })
  //   page.click('.action-dock__button--edit_poll')
  //   page.fillIn('.poll-common-form-fields__title', 'Yo reliability, whatsup? Its me, ya boi, testing')
  //   page.click('.poll-common-form__submit')
  //   page.expectElement('.announcement-form')
  //   page.click('.announcement-form__audience')
  //   page.click('.announcement-form__submit')
  //   page.expectFlash('1 notifications sent')
  // },

  // 'outcome_created': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('test_proposal_poll_closed', { controller: 'polls' })
  //   page.click('.poll-common-set-outcome-panel__submit')
  //   page.fillIn('.poll-common-outcome-form__statement textarea', 'Immannounce all yall')
  //   page.click('.poll-common-outcome-form__submit')
  //   page.expectFlash('Outcome created')
  //   page.expectElement('.announcement-form')
  //   page.selectFromAutocomplete('.announcement-form__invite input', 'test@example.com')
  //   page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
  //   page.click('.announcement-form__submit')
  //   page.pause(3000)
  //   page.expectFlash('1 notifications sent')
  // }
