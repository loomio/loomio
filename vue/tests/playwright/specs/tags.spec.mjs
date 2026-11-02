import { test, expect } from '../fixtures.mjs';

test('restricted_member_can_start_a_thread_with_template_tags', async ({ lmo: page }) => {
  await page.loadPath('setup_member_discussion_with_restricted_tags');
  await page.expectElement('.tags-field__input.v-autocomplete');
  await page.expectText('.tags-field__input .v-chip', 'Existing');
  await page.expectText('.tags-field__input', 'Template default');
  await page.fillIn('#discussion-title', 'Thread with existing tags');
  await page.fillIn('.tags-field__input input:not([type="hidden"])', 'Other');
  await page.click('.v-overlay--active .v-list-item');
  await page.expectText('.tags-field__input', 'Other');
  await page.fillIn('.tags-field__input input:not([type="hidden"])', 'Unauthorized new tag');
  await page.first('.tags-field__input input:not([type="hidden"])').press('Enter');
  await page.click('#discussion-title');
  await page.expectNoText('.tags-field__input .v-chip', 'Unauthorized new tag');
  await page.click('.discussion-form__submit');
  await page.expectFlash('Discussion started');
  await page.expectText('.context-panel__heading', 'Thread with existing tags');
  await page.expectText('.tags-display', 'Existing');
  await page.expectText('.tags-display', 'Other');
  await page.expectText('.tags-display', 'Template default');
  await page.expectNoText('.tags-display', 'Unauthorized new tag');
  await page.expectCount('.topic-header .tag-color-dot[style*="background-color"]', 3);
  await page.refreshAndWait();
  await page.expectText('.tags-display', 'Template default');
});
