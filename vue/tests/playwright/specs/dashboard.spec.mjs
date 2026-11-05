import { test, expect } from '../fixtures.mjs';
import { blockMainContentRequests } from '../helpers/initialPage.mjs';

test('shows recent threads but not old ones', async ({ page }) => {
  const requests = await blockMainContentRequests(page);
  await page.route('**/api/v1/profile/groups?*', route => route.abort());
  await page.goto('/dev/setup_dashboard')
  const threads = page.locator('.dashboard-page__collections')
  await expect(threads).toContainText('Poll discussion')
  await expect(threads).toContainText('Recent discussion')
  await expect(threads).not.toContainText('Old discussion')
  await expect(page.locator('.polls-panel')).toBeVisible();
  expect(requests).toEqual([]);
});

test('marks a thread as read', async ({ page, flash }) => {
  await page.goto('/dev/setup_dashboard_with_one_thread')
  await page.locator('.action-dock__button--dismiss_thread').click()
  await expect(flash).toContainText('Discussion marked as read')
});
