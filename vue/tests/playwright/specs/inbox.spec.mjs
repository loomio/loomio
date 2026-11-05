import { test, expect } from '../fixtures.mjs';

test('groups unread threads by group, without muted or old threads', async ({ page }) => {
  await page.goto('/dev/setup_inbox')
  await expect(page.locator('.inbox-page__group', { hasText: 'Dirty Dancing Shoes' })).toContainText('Pinned discussion')
  await expect(page.locator('.inbox-page__group', { hasText: 'Point Break' })).toContainText('Recent discussion')
  const inbox = page.locator('.inbox-page')
  await expect(inbox).not.toContainText('Muted discussion')
  await expect(inbox).not.toContainText('Old discussion')
});
