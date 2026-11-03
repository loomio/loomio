import { test, expect } from '../fixtures.mjs';

test('approves_a_stored_message_and_removes_it_from_the_pending_list', async ({ page }) => {
  await page.goto('/dev/setup_manual_oatmilk_unreleased_email')
  await expect(page.locator('.group-emails-panel')).toContainText('Returnable bottle collection proposal')
  await page.locator('.group-emails-panel__approve').click()
  await expect(page.locator('.v-overlay--active .v-card')).toContainText('Add alias')
  await page.locator('.v-overlay--active input').fill('Jamie')
  await expect(page.locator('.v-overlay--active .v-list-item')).toContainText('Jamie Chen')
  await page.locator('.v-overlay--active .v-card .v-list-item').click()
  await page.locator('.v-overlay--active .v-card-actions .v-btn:last-child').click()
  await expect(page.locator('.v-overlay--active .v-card-actions')).toHaveCount(0)
  await expect(page.locator('.group-emails-panel')).not.toContainText('Returnable bottle collection proposal')
  await expect(page.locator('.group-emails-panel__approve')).toHaveCount(0)
  await page.reload()
  await expect(page.locator('.group-emails-panel')).toBeVisible()
  await expect(page.locator('.group-emails-panel')).not.toContainText('Returnable bottle collection proposal')
});
