import { test, expect } from '../fixtures.mjs';

const nominationPrompt = 'Who are you nominating, and for which position?';
const threadForm = page => page.locator('.discussion-form');

test('the browse page lists templates', async ({ page }) => {
  await page.goto('/dev/setup_discussion_template_browse');
  const browse = page.locator('.discussion-templates-browse-page');
  await expect(browse).toContainText('Advice process');
  await expect(browse).toContainText('Consent process');
});

test('a non-member submits a nomination from a group template', async ({ page, flash }) => {
  await page.goto('/dev/setup_nonmember_nomination');
  await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes');
  await expect(page.locator('.join-group-button')).toHaveCount(0);
  await page.locator('.discussions-panel__new-topic-button').click();
  await page.locator('.discussion-templates--template', { hasText: 'Nominate a candidate' }).click();
  await expect(threadForm(page)).toContainText(nominationPrompt);
  await expect(page.locator('.common-notify-fields')).toHaveCount(0);
  await expect(flash).toHaveCount(0);
  await threadForm(page).locator('.discussion-form__title-input input').fill('Sam Rivera — Board chair');
  await threadForm(page).locator('.discussion-form__submit').click();
  await expect(flash).toContainText('Discussion started');
  await expect(page.locator('.context-panel__heading')).toContainText('Sam Rivera — Board chair');
  await expect(page.locator('.context-panel__description')).toContainText('Why is this person suitable?');
  await expect(page.locator('.action-dock__button--announce_thread')).toHaveCount(0);
});

test('a member opening a template form directly can notify the group', async ({ page }) => {
  await page.goto('/dev/setup_member_nomination_form');
  await expect(threadForm(page)).toContainText(nominationPrompt);
  await expect(threadForm(page).locator('.tags-field__input')).toBeVisible();
  await expect(threadForm(page).locator('.common-notify-fields')).toContainText('Dirty Dancing Shoes');
});

test('a non-member opening a template form directly cannot notify the group', async ({ page }) => {
  await page.goto('/dev/setup_nonmember_nomination_form');
  await expect(threadForm(page)).toContainText(nominationPrompt);
  await expect(threadForm(page).locator('.tags-field__input')).toHaveCount(0);
  await expect(page.locator('.common-notify-fields')).toHaveCount(0);
});
