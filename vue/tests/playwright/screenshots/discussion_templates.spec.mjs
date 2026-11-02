import { test, expect } from '../screenshotFixtures.mjs';

test('discussion_templates_list', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion_templates');
  await page.waitFor('.discussion-templates-page');
  await page.expectText('.discussion-templates-page', 'Bottle trial review');
  await screenshot.captureElement(
    'discussions/templates/list',
    '.discussion-templates-page .v-card',
    {width: 1100, height: 1800}
  );
});

test('discussion_template_form', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion_template_form');
  await page.waitFor('.discussion-template-form');
  await page.expectValue('.discussion-template-form-fields__title input', 'Returnable bottle trial review');
  await page.expectElement('.discussion-template-form-fields__title-placeholder input');
  await page.expectElement('.discussion-template-form__submit');
  await screenshot.captureElement(
    'discussions/templates/form',
    '.discussion-template-form',
    {width: 1100, height: 3200}
  );
});

test('discussion_from_template', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_discussion_from_template');
  await page.waitFor('.discussion-form');
  await page.expectValue('#discussion-title', 'Returnable bottle trial review');
  await page.waitFor('.discussion-form .common-notify-fields');
  await page.expectText('.discussion-form .common-notify-fields', 'Oatmilk Cooperative');
  await screenshot.captureElement(
    'discussions/templates/use',
    '.discussion-form',
    {width: 1100, height: 2600}
  );
});
