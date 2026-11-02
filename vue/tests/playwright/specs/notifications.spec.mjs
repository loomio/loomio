import { test, expect } from '../fixtures.mjs';

test('has_all_the_notifications', async ({ page }) => {
  await page.goto('/dev/setup_all_notifications')
  await page.click('.notifications__button')
  await expect(page.locator('.notifications__dropdown')).toContainText('invited you to a group')
  await expect(page.locator('.notifications__dropdown')).toContainText('accepted your invitation to join')
  await expect(page.locator('.notifications__dropdown')).toContainText('invited you to join')
  await expect(page.locator('.notifications__dropdown')).toContainText('approved your request')
  await expect(page.locator('.notifications__dropdown')).toContainText('requested to join')
  await expect(page.locator('.notifications__dropdown')).toContainText('mentioned you in')
  await expect(page.locator('.notifications__dropdown')).toContainText('replied to you in')
  await expect(page.locator('.notifications__dropdown')).toContainText('published a proposal outcome')
  await expect(page.locator('.notifications__dropdown')).toContainText('poll closing in 24 hours')
  await expect(page.locator('.notifications__dropdown')).toContainText('invited you to vote')
  await expect(page.locator('.notifications__dropdown')).toContainText('reacted 🙂 to your comment')
  await expect(page.locator('.notifications__dropdown')).toContainText('made you an admin')
});
