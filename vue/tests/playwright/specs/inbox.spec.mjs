import { test, expect } from '../fixtures.mjs';

test('displays_unread_threads_by_group', async ({ lmo: page }) => {
  await page.loadPath('setup_inbox')
  await page.expectText('.inbox-page__group', 'Dirty Dancing Shoes')
  await page.expectText('.inbox-page', 'Pinned discussion')
  await page.expectText('.inbox-page', 'Point Break')
  await page.expectText('.inbox-page', 'Recent discussion')
  await page.expectNoText('.inbox-page', 'Muted discussion')
  await page.expectNoText('.inbox-page', 'Old discussion')
});
