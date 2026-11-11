import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

const SUGGESTIONS = '.v-overlay--active .v-list:has(.recipients-autocomplete-suggestion)';

async function prepareParentGroupInvitation(page) {
  await page.setViewportSize({ width: 1100, height: 800 });
  await page.goto('/dev/setup_manual_oatmilk_invite_thread?view=subgroup');
  await expectLabel(page.locator('.context-panel__heading'), 'Bottle trial feedback from the cooperative');
  await page.locator('.topic-sidebar .action-dock__button--announce_thread').click();
  const members = page.locator('.topic-members-list');
  await members.locator('.recipients-autocomplete input[type="text"]').click();
  await page.locator('.v-overlay--active .recipients-autocomplete-suggestion--group', { hasText: 'Oatmilk Cooperative' }).click();
  await expectLabel(members.locator('.chip--select-multi'), 'Oatmilk Cooperative');
  await expectLabel(members.locator('.common-notifications-count'), '2');
  await members.locator('textarea').fill('The Bottle Trial Board would like everyone in the cooperative to review the plan. Please share questions about deposits, collection days, and washing capacity.');
  await members.locator('.v-card-title').click();
  await expect(page.locator(SUGGESTIONS)).toHaveCount(0);
  return members;
}

test('thread_invite', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1100, height: 1000 });
  await page.goto('/dev/setup_manual_oatmilk_invite_thread');
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers');
  await page.locator('.topic-sidebar .action-dock__button--announce_thread').click();
  await expect(page.locator('.topic-members-list__readers')).toContainText('Samira Patel');
  await page.locator('.topic-members-list .recipients-autocomplete input[type="text"]').click();
  for (const label of ['Oatmilk Cooperative', 'Delegates of Oatmilk Cooperative', 'Oatmilk Cooperative chat', 'Bottle Trial Board']) {
    await expectLabel(page.locator(SUGGESTIONS), label);
  }
  await screenshot.captureRegion(
    'discussions/inviting_people/thread_invite',
    ['.topic-members-list', SUGGESTIONS],
    { width: 1100, height: 1000, padding: 24, spotlight: { selectors: ['.topic-members-list .recipients-autocomplete', SUGGESTIONS], padding: 12, radius: 16, opacity: 0.3, outlineWidth: 0 } }
  );
});

test('thread_invite_parent_group', async ({ page, manual: screenshot }) => {
  await prepareParentGroupInvitation(page);
  await screenshot.captureRegion(
    'discussions/inviting_people/thread_invite_parent_group',
    ['.topic-members-list'],
    { width: 1100, height: 800, padding: 24, spotlight: { selector: '.topic-members-list .recipients-autocomplete', padding: 14, radius: 16, opacity: 0.3, outlineWidth: 0 } }
  );
});

test('thread_invite_expand', async ({ page, manual: screenshot }) => {
  const members = await prepareParentGroupInvitation(page);
  await members.locator('.chip--select-multi').click();
  await expect(members.locator('.chip--select-multi')).toHaveCount(2);
  const samira = members.locator('.chip--select-multi', { hasText: 'Samira Patel' });
  const alex = members.locator('.chip--select-multi', { hasText: 'Alex Morgan' });
  await expect(samira).toBeVisible();
  await expect(alex).toBeVisible();
  await members.locator('.v-card-title').click();
  await expect(page.locator(SUGGESTIONS)).toHaveCount(0);
  await screenshot.captureRegion(
    'discussions/inviting_people/thread_invite_expand',
    ['.topic-members-list'],
    { width: 1100, height: 800, padding: 24, spotlight: { selector: '.topic-members-list .recipients-autocomplete', padding: 14, radius: 16, opacity: 0.3, outlineWidth: 0 } }
  );
  await alex.locator('.v-chip__close').click();
  await expect(alex).toHaveCount(0);
  await expect(samira).toBeVisible();
  await expectLabel(members.locator('.common-notifications-count'), '1');
});
