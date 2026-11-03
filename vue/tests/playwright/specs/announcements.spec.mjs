import { test, expect } from '../fixtures.mjs';

test('invite_to_group', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.membership-card__invite').click()
  await page.locator('.recipients-autocomplete input[type="text"]').fill('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.locator('.recipients-autocomplete-suggestion').click()
  await page.locator('.announcement-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('1 notifications sent')
});

test('expand_parent_group_members_when_inviting_to_a_subgroup', async ({ page }) => {
  await page.goto('/dev/setup_subgroup_invitation_audiences')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.membership-card__invite').click()
  await page.locator('.recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.v-autocomplete__content')).toContainText('Point Break')
  await page.locator('.recipients-autocomplete-suggestion', { hasText: 'Point Break' }).first().click()
  await page.locator('.recipients-autocomplete .chip--select-multi').click()
  await expect(page.locator('.recipients-autocomplete')).toContainText('Max Von Sydow')
  await expect(page.locator('.recipients-autocomplete')).not.toContainText('Jennifer Grey')
});

test('invite_parent_group_members_to_a_subgroup_without_expanding_the_audience', async ({ page }) => {
  await page.goto('/dev/setup_subgroup_invitation_audiences')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.membership-card__invite').click()
  await page.locator('.recipients-autocomplete input[type="text"]').click()
  await page.locator('.recipients-autocomplete-suggestion', { hasText: 'Point Break' }).first().click()
  await page.locator('.announcement-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('1 notifications sent')
  await expect(page.locator('.members-panel')).toContainText('Max Von Sydow')
});

  // discussion form
test('new_discussion', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.locator('.discussions-panel__new-topic-button').click()
  await page.locator('.discussion-templates--template').click()
  await page.locator('.recipients-autocomplete input[type="text"]').fill('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.locator('.recipients-autocomplete-suggestion').click()
  await page.locator('.discussion-form__title-input input').fill('Immannounce dis')
  await page.locator('.discussion-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Discussion started')
});

test('new_direct_discussion_autocompletes_recipients_without_a_group', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.navbar__sidenav-toggle').click()
  await page.locator('.sidebar__list-item-button--private').click()
  await page.locator('.topics-page__new-topic-button').click()
  await page.locator('.discussion-templates--direct-discussion').click()
  await expect(page.locator('.discussion-form')).toBeVisible()
  await page.locator('.recipients-autocomplete input[type="text"]').fill('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
});

  // topic members list
test('announcement_created', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.action-dock__button--announce_thread').click()
  await expect(page.locator('.topic-members-list')).toBeVisible()
  await page.locator('.recipients-autocomplete input[type="text"]').fill('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.locator('.recipients-autocomplete-suggestion').click()
  await page.keyboard.press('Escape')
  await page.locator('.topic-members-list__submit').click()
  await expect(page.locator('.topic-members-list')).toContainText('test@example.com')
  await expect(page.locator('.flash-root__message')).toContainText('1 notifications sent')
});

test('announcement_autocompletes_group_member_names', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.action-dock__button--announce_thread').click()
  await expect(page.locator('.topic-members-list')).toBeVisible()
  await page.locator('.recipients-autocomplete input[type="text"]').fill('Emilio')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('Emilio Estevez')
});

test('pages_and_filters_thread_members', async ({ page }) => {
  await page.goto('/dev/setup_discussion_many_members')
  await page.locator('.action-dock__button--announce_thread').click()
  await expect(page.locator('.topic-members-list')).toContainText('Manage thread members')
  await expect(page.locator('.topic-members-list .help-link')).toContainText('Help')
  await expect(page.locator('.topic-members-list__page-count')).toContainText('1–50 of 52')
  await expect(page.locator('.topic-members-list__readers')).toContainText('Thread member 50')
  await page.locator('.topic-members-list__pagination .v-pagination__next button').click()
  await expect(page.locator('.topic-members-list__page-count')).toContainText('51–52 of 52')
  await page.locator('.recipients-autocomplete input[type="text"]').fill('Thread member 50')
  await expect(page.locator('.topic-members-list__page-count')).toContainText('1–1 of 1')
  await page.locator('.topic-members-list__page-count').click()
  await expect(page.locator('.recipients-autocomplete input[type="text"]')).toHaveValue('Thread member 50')
  await page.locator('.recipients-autocomplete .v-field__clearable').click()
  await expect(page.locator('.topic-members-list__page-count')).toContainText('1–50 of 52')
  await expect(page.locator('.topic-members-list textarea')).toHaveCount(0)
  await expect(page.locator('.topic-members-list__submit')).toHaveCount(0)
  await page.locator('.recipients-autocomplete input[type="text"]').fill('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.locator('.recipients-autocomplete-suggestion').click()
  await expect(page.locator('.topic-members-list textarea')).toBeVisible()
  await expect(page.locator('.topic-members-list__submit')).toBeVisible()
  await expect(page.locator('.topic-members-list')).toContainText('New people will be invited to the thread')
  await expect(page.locator('.topic-members-list__readers')).toHaveCount(0)
  await page.locator('.recipients-autocomplete .v-field__clearable').click()
  await expect(page.locator('.topic-members-list__readers')).toBeVisible()
  await page.locator('.topic-members-list .v-alert__close button').click()
  await expect(page.locator('.topic-members-list')).not.toContainText('Guests invited by email can participate')
  await page.locator('.topic-members-list .dismiss-modal-button').click()
  await page.locator('.action-dock__button--announce_thread').click()
  await expect(page.locator('.topic-members-list')).not.toContainText('Guests invited by email can participate')
});

  // poll members list
test('poll_created', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.decision-tools-card__template--check').click()
  await page.locator('.poll-common-form-fields__title input').fill('A new proposal')
  await page.locator('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]').fill('Some details')
  await page.locator('.poll-common-settings__specified-voters-only label').click()
  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Proposal started')

  await expect(page.locator('.poll-members-form')).toBeVisible()
  await page.locator('.recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.recipients-autocomplete-suggestion')).toBeVisible()
  await expect(page.locator('.v-autocomplete__content')).not.toContainText('Everyone in the thread')
  await page.locator('.recipients-autocomplete input[type="text"]').fill('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.locator('.recipients-autocomplete-suggestion').click()
  await page.keyboard.press('Escape')
  await page.locator('.poll-members-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('1 notifications sent')
});
