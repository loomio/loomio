import { test, expect } from '../fixtures.mjs';
import { blockMainContentRequests } from '../helpers/initialPage.mjs';

test('groups unread threads by group, without muted or old threads', async ({ page }) => {
  const requests = await blockMainContentRequests(page);
  await page.route('**/api/v1/profile/groups?*', route => route.abort());
  await page.goto('/dev/setup_inbox')
  await expect(page.locator('.inbox-page__group', { hasText: 'Dirty Dancing Shoes' })).toContainText('Pinned discussion')
  await expect(page.locator('.inbox-page__group', { hasText: 'Point Break' })).toContainText('Recent discussion')
  const inbox = page.locator('.inbox-page')
  await expect(inbox).not.toContainText('Muted discussion')
  await expect(inbox).not.toContainText('Old discussion')
  expect(requests).toEqual([]);
});
