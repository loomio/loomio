import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

test('discussion_templates_list', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion_templates')
  await expect(page.locator('.discussion-templates-page').first()).toBeVisible()
  await expectLabel(page.locator('.discussion-templates-page'), 'Bottle trial review')
  await screenshot.captureElement(
    'discussions/templates/list',
    '.discussion-templates-page .v-card',
    {width: 1100, height: 1800}
  );
});

test('discussion_template_form', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion_template_form')
  await expect(page.locator('.discussion-template-form').first()).toBeVisible()
  await expect(page.locator('.discussion-template-form-fields__title input')).toHaveValue('Returnable bottle trial review')
  await expect(page.locator('.discussion-template-form-fields__title-placeholder input').first()).toBeVisible()
  await expect(page.locator('.discussion-template-form__submit').first()).toBeVisible()
  await screenshot.captureElement(
    'discussions/templates/form',
    '.discussion-template-form',
    {width: 1100, height: 3200}
  );
});

test('discussion_from_template', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion_from_template')
  await expect(page.locator('.discussion-form').first()).toBeVisible()
  await expect(page.locator('#discussion-title')).toHaveValue('Returnable bottle trial review')
  await expect(page.locator('.discussion-form .common-notify-fields').first()).toBeVisible()
  await expectLabel(page.locator('.discussion-form .common-notify-fields'), 'Oatmilk Cooperative')
  await screenshot.captureElement(
    'discussions/templates/use',
    '.discussion-form',
    {width: 1100, height: 2600}
  );
});
