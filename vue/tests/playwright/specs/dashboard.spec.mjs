import { test, expect } from '../fixtures.mjs';

test('displays_a_view_of_recent_threads', async ({ page }) => {
  await page.goto('/dev/setup_dashboard')
  await expect(page.locator('.dashboard-page__collections')).toContainText('Poll discussion')
  await expect(page.locator('.dashboard-page__collections')).toContainText('Recent discussion')
  await expect(page.locator('.dashboard-page__collections')).not.toContainText('Old discussion')
});

test('dismisses_a_thread', async ({ page }) => {
  await page.goto('/dev/setup_dashboard_with_one_thread')
  await expect(page.locator('.topic-previews-container')).toBeVisible()
  await page.click('.action-dock__button--dismiss_thread')
  await expect(page.locator('.flash-root__message')).toContainText('Discussion marked as read')
});

