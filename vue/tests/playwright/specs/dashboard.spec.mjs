import { test, expect } from '../fixtures.mjs';

test('shows recent threads but not old ones', async ({ page }) => {
  await page.goto('/dev/setup_dashboard')
  const threads = page.locator('.dashboard-page__collections')
  await expect(threads).toContainText('Poll discussion')
  await expect(threads).toContainText('Recent discussion')
  await expect(threads).not.toContainText('Old discussion')
});

test('marks a thread as read', async ({ page, flash }) => {
  await page.goto('/dev/setup_dashboard_with_one_thread')
  await page.locator('.action-dock__button--dismiss_thread').click()
  await expect(flash).toContainText('Discussion marked as read')
});
