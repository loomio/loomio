import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import richText, { fillRichText } from '../helpers/oatmilkRichText.mjs';

test('new_discussion_action', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_new_discussion')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await expectLabel(page.locator('.discussions-panel__new-topic-button'), 'New discussion')
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

test('new_discussion_form', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_new_discussion')
  await page.locator('.discussions-panel__new-topic-button').click()
  await page.locator('.discussion-templates--template-blank').click()
  const form = page.locator('.discussion-form')
  const title = form.locator('.discussion-form__title-input input')
  await title.fill('Plan the returnable bottle trial')
  await fillRichText(editor(form), richText.context('new-discussion', [
    'Several cafes want to trial returnable glass bottles, and each cafe has offered to record returns for six weeks.',
    'We need to compare collection options, cleaning requirements, and transport costs before agreeing on a plan.',
    'Add practical questions, dependencies, and anything cafe staff will need before the trial begins.'
  ]))
  // Tags have no classes of their own, so they are picked by name.
  await form.locator('.tags-field__input .v-field').click()
  for (const tag of ['Sustainability', 'Packaging']) {
    await page.locator('.v-overlay--active .v-list-item', { hasText: tag }).click()
  }
  await title.click()
  await title.blur()
  await expect(title).toHaveValue('Plan the returnable bottle trial')
  await expect(page.locator('.v-overlay--active')).toHaveCount(0)
  await screenshot.captureElement('discussions/starting_a_discussion/new-discussion-example', '.discussion-form', {
    height: 1200
  });
});
