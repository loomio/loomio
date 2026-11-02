import { test, expect } from '../fixtures.mjs';

test('discussion_form_shows_validation_errors', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.action-dock__button--edit_thread')
  await page.fill('.discussion-form__title-input input', '')
  await page.click('.discussion-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Please check')
  await expect(page.locator('.flash-root__message')).toContainText('title')
});

test('group_form_shows_validation_errors', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.fill('#group-name', '')
  await page.click('.group-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('name')
});

test('poll_form_shows_validation_errors', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion')
  await page.click('.activity-panel__add-poll')
  await page.click('.decision-tools-card__poll-type--proposal')
  await page.fill('.poll-common-form-fields__title input', '')
  await page.click('.poll-common-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('title')
});
