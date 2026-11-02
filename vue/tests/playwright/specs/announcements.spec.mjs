import { test, expect } from '../fixtures.mjs';

test('invite_to_group', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.click('.group-page-members-tab')
  await page.click('.membership-card__invite')
  await page.locator('.recipients-autocomplete input[type="text"]').pressSequentially('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.click('.announcement-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('1 notifications sent')
});

test('expand_parent_group_members_when_inviting_to_a_subgroup', async ({ page }) => {
  await page.goto('/dev/setup_subgroup_invitation_audiences')
  await page.click('.group-page-members-tab')
  await page.click('.membership-card__invite')
  await page.click('.recipients-autocomplete input[type="text"]')
  await expect(page.locator('.v-autocomplete__content')).toContainText('Point Break')
  await page.locator('.recipients-autocomplete-suggestion', { hasText: 'Point Break' }).first().click()
  await page.click('.recipients-autocomplete .chip--select-multi')
  await expect(page.locator('.recipients-autocomplete')).toContainText('Max Von Sydow')
  await expect(page.locator('.recipients-autocomplete')).not.toContainText('Jennifer Grey')
});

test('invite_parent_group_members_to_a_subgroup_without_expanding_the_audience', async ({ page }) => {
  await page.goto('/dev/setup_subgroup_invitation_audiences')
  await page.click('.group-page-members-tab')
  await page.click('.membership-card__invite')
  await page.click('.recipients-autocomplete input[type="text"]')
  await page.locator('.recipients-autocomplete-suggestion', { hasText: 'Point Break' }).first().click()
  await page.click('.announcement-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('1 notifications sent')
  await expect(page.locator('.members-panel')).toContainText('Max Von Sydow')
});

  // discussion form
test('new_discussion', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.click('.discussions-panel__new-topic-button')
  await page.click('.discussion-templates--template')
  await page.locator('.recipients-autocomplete input[type="text"]').pressSequentially('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.fill('.discussion-form__title-input input', 'Immannounce dis')
  await page.click('.discussion-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Discussion started')
});

test('new_direct_discussion_autocompletes_recipients_without_a_group', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar__list-item-button--private')
  await page.click('.topics-page__new-topic-button')
  await page.click('.discussion-templates--direct-discussion')
  await expect(page.locator('.discussion-form')).toBeVisible()
  await page.locator('.recipients-autocomplete input[type="text"]').pressSequentially('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
});

  // topic members list
test('announcement_created', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.action-dock__button--announce_thread')
  await expect(page.locator('.topic-members-list')).toBeVisible()
  await page.locator('.recipients-autocomplete input[type="text"]').pressSequentially('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.keyboard.press('Escape')
  await page.click('.topic-members-list__submit')
  await expect(page.locator('.topic-members-list')).toContainText('test@example.com')
  await expect(page.locator('.flash-root__message')).toContainText('1 notifications sent')
});

test('announcement_autocompletes_group_member_names', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.action-dock__button--announce_thread')
  await expect(page.locator('.topic-members-list')).toBeVisible()
  await page.fill('.recipients-autocomplete input[type="text"]', 'Emilio')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('Emilio Estevez')
});

test('pages_and_filters_thread_members', async ({ page }) => {
  await page.goto('/dev/setup_discussion_many_members')
  await page.click('.action-dock__button--announce_thread')
  await expect(page.locator('.topic-members-list')).toContainText('Manage thread members')
  await expect(page.locator('.topic-members-list .help-link')).toContainText('Help')
  await expect(page.locator('.topic-members-list__page-count')).toContainText('1–50 of 52')
  await expect(page.locator('.topic-members-list__readers')).toContainText('Thread member 50')
  await page.click('.topic-members-list__pagination .v-pagination__next button')
  await expect(page.locator('.topic-members-list__page-count')).toContainText('51–52 of 52')
  await page.fill('.recipients-autocomplete input[type="text"]', 'Thread member 50')
  await expect(page.locator('.topic-members-list__page-count')).toContainText('1–1 of 1')
  await page.click('.topic-members-list__page-count')
  await expect(page.locator('.recipients-autocomplete input[type="text"]')).toHaveValue('Thread member 50')
  await page.click('.recipients-autocomplete .v-field__clearable')
  await expect(page.locator('.topic-members-list__page-count')).toContainText('1–50 of 52')
  await expect(page.locator('.topic-members-list textarea')).toHaveCount(0)
  await expect(page.locator('.topic-members-list__submit')).toHaveCount(0)
  await page.locator('.recipients-autocomplete input[type="text"]').pressSequentially('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await expect(page.locator('.topic-members-list textarea')).toBeVisible()
  await expect(page.locator('.topic-members-list__submit')).toBeVisible()
  await expect(page.locator('.topic-members-list')).toContainText('New people will be invited to the thread')
  await expect(page.locator('.topic-members-list__readers')).toHaveCount(0)
  await page.click('.recipients-autocomplete .v-field__clearable')
  await expect(page.locator('.topic-members-list__readers')).toBeVisible()
  await page.click('.topic-members-list .v-alert__close button')
  await expect(page.locator('.topic-members-list')).not.toContainText('Guests invited by email can participate')
  await page.click('.topic-members-list .dismiss-modal-button')
  await page.click('.action-dock__button--announce_thread')
  await expect(page.locator('.topic-members-list')).not.toContainText('Guests invited by email can participate')
});

  // poll members list
test('poll_created', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.activity-panel__add-poll')
  await page.click('.decision-tools-card__poll-type--proposal')
  await page.fill('.poll-common-form-fields__title input', 'A new proposal')
  await page.fill('.poll-common-form-fields__details .lmo-textarea div[contenteditable=true]', 'Some details')
  await page.click('.poll-common-settings__specified-voters-only label')
  await page.click('.poll-common-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Proposal started')

  await expect(page.locator('.poll-members-form')).toBeVisible()
  await page.click('.recipients-autocomplete input[type="text"]')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toBeVisible()
  await expect(page.locator('.v-autocomplete__content')).not.toContainText('Everyone in the thread')
  await page.locator('.recipients-autocomplete input[type="text"]').pressSequentially('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.keyboard.press('Escape')
  await page.click('.poll-members-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('1 notifications sent')
});
