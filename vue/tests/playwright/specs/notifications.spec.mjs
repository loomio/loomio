import { test, expect } from '../fixtures.mjs';

test('lists every kind of notification', async ({ page }) => {
  await page.goto('/dev/setup_all_notifications')
  await page.locator('.notifications__button').click()
  const notifications = page.locator('.notifications__dropdown')
  for (const text of [
    'invited you to a group',
    'accepted your invitation to join',
    'invited you to join',
    'approved your request',
    'requested to join',
    'mentioned you in',
    'replied to you in',
    'published a proposal outcome',
    'poll closing in 24 hours',
    'invited you to vote',
    'reacted 🙂 to your comment',
    'made you an admin',
  ]) {
    await expect(notifications).toContainText(text)
  }
});
