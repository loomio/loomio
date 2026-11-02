import { test, expect } from '../fixtures.mjs';

test('has_all_the_notifications', async ({ lmo: page }) => {
  await page.loadPath('setup_all_notifications')
  await page.pause(500)
  await page.click('.notifications__button')
  await page.expectText('.notifications__dropdown', 'invited you to a group')
  await page.expectText('.notifications__dropdown', 'accepted your invitation to join')
  await page.expectText('.notifications__dropdown', 'invited you to join')
  await page.expectText('.notifications__dropdown', 'approved your request')
  await page.expectText('.notifications__dropdown', 'requested to join')
  await page.expectText('.notifications__dropdown', 'mentioned you in')
  await page.expectText('.notifications__dropdown', 'replied to you in' )
  await page.expectText('.notifications__dropdown', 'published a proposal outcome')
  await page.expectText('.notifications__dropdown', 'poll closing in 24 hours')
  await page.expectText('.notifications__dropdown', 'invited you to vote')
  await page.expectText('.notifications__dropdown', 'reacted 🙂 to your comment')
  await page.expectText('.notifications__dropdown', 'made you an admin')
});
