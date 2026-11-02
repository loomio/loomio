import { test, expect } from '../fixtures.mjs';

test('displays_unread_threads_by_group', async ({ page }) => {
  await page.goto('/dev/setup_inbox')
  await expect(page.locator('.inbox-page__group')).toContainText('Dirty Dancing Shoes')
  await expect(page.locator('.inbox-page')).toContainText('Pinned discussion')
  await expect(page.locator('.inbox-page')).toContainText('Point Break')
  await expect(page.locator('.inbox-page')).toContainText('Recent discussion')
  await expect(page.locator('.inbox-page')).not.toContainText('Muted discussion')
  await expect(page.locator('.inbox-page')).not.toContainText('Old discussion')
});
