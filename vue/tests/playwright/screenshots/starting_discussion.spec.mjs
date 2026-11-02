import { test, expect } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

test('new_discussion_action', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_new_discussion');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.expectText('.discussions-panel__new-topic-button', 'New discussion');
  await screenshot.capture('discussions/starting_a_discussion/new-discussion-button', {
    spotlight: {
      selector: '.discussions-panel__new-topic-button',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('new_discussion_form', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_new_discussion');
  await page.click('.discussions-panel__new-topic-button');
  await page.waitFor('.discussion-templates--template');
  await page.click('.discussion-templates--template-blank');
  await page.waitFor('.discussion-form');
  await page.fillIn('.discussion-form__title-input input', 'Plan the returnable bottle trial');
  await page.fillRichText(
    '.discussion-form .lmo-textarea div[contenteditable=true]',
    richText.context('new-discussion', [
      'Several cafes want to trial returnable glass bottles, and each cafe has offered to record returns for six weeks.',
      'We need to compare collection options, cleaning requirements, and transport costs before agreeing on a plan.',
      'Add practical questions, dependencies, and anything cafe staff will need before the trial begins.'
    ])
  );
  await page.click('.tags-field__input .v-field');
  await page.waitFor('.v-overlay .v-list-item');
  await page.execute("Array.from(document.querySelectorAll('.v-overlay .v-list-item')).find(el => el.textContent.includes('Sustainability')).click()");
  await page.click('.tags-field__input .v-field');
  await page.waitFor('.v-overlay .v-list-item');
  await page.execute("Array.from(document.querySelectorAll('.v-overlay .v-list-item')).find(el => el.textContent.includes('Packaging')).click()");
  await page.click('.discussion-form__title-input input');
  await page.execute('document.activeElement.blur()');
  await page.pause(200);
  await page.expectValue('.discussion-form__title-input input', 'Plan the returnable bottle trial');
  await screenshot.captureElement('discussions/starting_a_discussion/new-discussion-example', '.discussion-form', {
    height: 1200
  });
});
