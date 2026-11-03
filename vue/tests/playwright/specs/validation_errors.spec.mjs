import { test, expect } from '../fixtures.mjs';
import { openPollForm } from '../helpers/polls.mjs';

test('the thread form reports a missing title', async ({ page, flash }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.action-dock__button--edit_thread').click()
  await page.locator('.discussion-form__title-input input').fill('')
  await page.locator('.discussion-form__submit').click()
  await expect(flash).toContainText(/Please check.*title/)
});

test('the group form reports a missing name', async ({ page, flash }) => {
  await page.goto('/dev/setup_group')
  await page.locator('.action-menu').click()
  await page.locator('.action-dock__button--edit_group').click()
  await page.locator('#group-name').fill('')
  await page.locator('.group-form__submit-button').click()
  await expect(flash).toContainText('name')
});

test('the poll form reports a missing title', async ({ page, flash }) => {
  await page.goto('/dev/polls/test_discussion')
  await openPollForm(page, 'check')
  await page.locator('.poll-common-form__submit').click()
  await expect(flash).toContainText('title')
});
