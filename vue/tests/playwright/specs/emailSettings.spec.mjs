import { test, expect } from '../fixtures.mjs';
import { choose } from '../helpers/vuetify.mjs';
import { ensureSidebar } from '../helpers/groups.mjs';

test('updates the catch-up email schedule from the user menu', async ({ page, flash }) => {
  await page.goto('/dev/setup_group')
  await ensureSidebar(page)
  await page.locator('.sidebar__user-dropdown').click()
  await page.locator('.user-dropdown__list-item-button--email-settings').click()
  await choose(page, '.email-settings-page__digest-card', 'Monday')
  await page.locator('.email-settings-page__update-button').click()
  await expect(flash).toContainText('Email settings updated')
});

test('hides push settings when no device is registered', async ({ page }) => {
  await page.goto('/dev/setup_manual_oatmilk_email_settings')
  await expect(page.locator('.email-settings-page__push-status-loaded')).toBeAttached()
  await expect(page.locator('.email-settings-page__push-column')).toHaveCount(0)
  await expect(page.locator('.email-settings-page__group-notifications-card')).not.toContainText('email and push')
});
