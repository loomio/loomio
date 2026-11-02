import { test, expect } from '../fixtures.mjs';

test('approves_a_stored_message_and_removes_it_from_the_pending_list', async ({ lmo: page }) => {
  await page.loadPath('setup_manual_oatmilk_unreleased_email');
  await page.expectText('.group-emails-panel', 'Returnable bottle collection proposal');
  await page.click('.group-emails-panel__approve');
  await page.expectText('.v-overlay--active .v-card', 'Add alias');
  await page.fillIn('.v-overlay--active input', 'Jamie');
  await page.expectText('.v-overlay--active .v-list-item', 'Jamie Chen');
  await page.click('.v-overlay--active .v-card .v-list-item');
  await page.click('.v-overlay--active .v-card-actions .v-btn:last-child');
  await page.expectNoElement('.v-overlay--active .v-card-actions');
  await page.expectNoText('.group-emails-panel', 'Returnable bottle collection proposal');
  await page.expectNoElement('.group-emails-panel__approve');
  await page.refresh();
  await page.waitFor('.group-emails-panel');
  await page.expectNoText('.group-emails-panel', 'Returnable bottle collection proposal');
});
