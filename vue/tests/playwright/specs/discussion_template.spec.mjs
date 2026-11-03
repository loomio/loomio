import { test, expect } from '../fixtures.mjs';

test('browse_page_displays_templates', async ({ page }) => {
  await page.goto('/dev/setup_discussion_template_browse')
  await expect(page.locator('.discussion-templates-browse-page')).toContainText('Advice process')
  await expect(page.locator('.discussion-templates-browse-page')).toContainText('Consent process')
});

test('nonmember_can_submit_a_nomination_from_a_group_template', async ({ page }) => {
  await page.goto('/dev/setup_nonmember_nomination')
  await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes')
  await expect(page.locator('.join-group-button')).toHaveCount(0)
  await page.locator('.discussions-panel__new-topic-button').click()
  await expect(page.locator('.discussion-templates-page')).toContainText('Nominate a candidate')
  await page.locator('.discussion-templates--template').click()
  await expect(page.locator('.discussion-form')).toContainText('Who are you nominating, and for which position?')
  await expect(page.locator('.common-notify-fields')).toHaveCount(0)
  await expect(page.locator('.flash-root__message')).toHaveCount(0)
  await page.locator('.discussion-form__title-input input').fill('Sam Rivera — Board chair')
  await page.locator('.discussion-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Discussion started')
  await expect(page.locator('.context-panel__heading')).toContainText('Sam Rivera — Board chair')
  await expect(page.locator('.context-panel__description')).toContainText('Why is this person suitable?')
  await expect(page.locator('.action-dock__button--announce_thread')).toHaveCount(0)
});

test('member_loading_a_template_form_directly_can_notify_the_group', async ({ page }) => {
  await page.goto('/dev/setup_member_nomination_form')
  await expect(page.locator('.discussion-form')).toContainText('Who are you nominating, and for which position?')
  await expect(page.locator('.discussion-form .tags-field__input')).toBeVisible()
  await expect(page.locator('.discussion-form .common-notify-fields')).toContainText('Dirty Dancing Shoes')
});

test('nonmember_loading_a_template_form_directly_cannot_notify_the_group', async ({ page }) => {
  await page.goto('/dev/setup_nonmember_nomination_form')
  await expect(page.locator('.discussion-form')).toContainText('Who are you nominating, and for which position?')
  await expect(page.locator('.discussion-form .tags-field__input')).toHaveCount(0)
  await expect(page.locator('.common-notify-fields')).toHaveCount(0)
});
