import { test, expect } from '../fixtures.mjs';

test('discussion_form_shows_validation_errors', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.action-dock__button--edit_thread').click()
  await page.locator('.discussion-form__title-input input').fill('')
  await page.locator('.discussion-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Please check')
  await expect(page.locator('.flash-root__message')).toContainText('title')
});

test('group_form_shows_validation_errors', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.locator('.action-menu').click()
  await page.locator('.action-dock__button--edit_group').click()
  await page.locator('#group-name').fill('')
  await page.locator('.group-form__submit-button').click()
  await expect(page.locator('.flash-root__message')).toContainText('name')
});

test('poll_form_shows_validation_errors', async ({ page }) => {
  await page.goto('/dev/polls/test_discussion')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.decision-tools-card__poll-type--proposal').click()
  await page.locator('.poll-common-form-fields__title input').fill('')
  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('title')
});
