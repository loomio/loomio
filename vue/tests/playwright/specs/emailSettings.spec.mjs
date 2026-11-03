import { test, expect } from '../fixtures.mjs';

test('lets_you_update_email_settings_while_logged_in', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await page.locator('.navbar__sidenav-toggle').click()
  await page.locator('.sidebar__user-dropdown').click()
  await page.locator('.user-dropdown__list-item-button--email-settings').click()
  await expect(page.locator('.email-settings-page__deactivate-card')).toBeVisible()
  await testUpdate(page)
});

test('hides_push_group_settings_without_a_registered_device', async ({ page }) => {
  await page.goto('/dev/setup_manual_oatmilk_email_settings')
  await expect(page.locator('.email-settings-page__push-status-loaded')).toBeVisible()
  await expect(page.locator('.email-settings-page__push-column')).toHaveCount(0)
  await expect(page.locator('.email-settings-page__group-notifications-card')).not.toContainText('email and push')
});

const testUpdate = async (page) => {
  await page.locator('.email-settings-page__digest-card .v-select .v-field').click()
  await expect(page.locator('.v-overlay--active .v-list')).toBeVisible()
  await page.locator('.v-overlay--active .v-list-item', { hasText: 'Monday' }).first().click()
  await page.locator('.email-settings-page__update-button').click()
  await expect(page.locator('.flash-root__message')).toContainText('Email settings updated')
}
