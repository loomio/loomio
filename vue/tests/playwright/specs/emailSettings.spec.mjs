import { test, expect } from '../fixtures.mjs';

test('lets_you_update_email_settings_while_logged_in', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.ensureSidebar()
  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--email-settings')
  await page.expectElement('.email-settings-page__deactivate-card')
  await testUpdate(page)
});

test('hides_push_group_settings_without_a_registered_device', async ({ lmo: page }) => {
  await page.loadPath('setup_manual_oatmilk_email_settings')
  await page.waitFor('.email-settings-page__push-status-loaded')
  await page.expectNoElement('.email-settings-page__push-column')
  await page.expectNoText('.email-settings-page__group-notifications-card', 'email and push')
});

const testUpdate = async (page) => {
  await page.click('.email-settings-page__digest-card .v-select .v-field')
  await page.waitFor('.v-overlay--active .v-list')
  await page.execute("Array.from(document.querySelectorAll('.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Monday')).click()")
  await page.click('.email-settings-page__update-button')
  await page.expectFlash('Email settings updated')
}
