import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

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
  await expect(page.locator('.discussion-templates--template').first()).toBeVisible()
  await page.locator('.discussion-templates--template-blank').click()
  await expect(page.locator('.discussion-form').first()).toBeVisible()
  await page.locator('.discussion-form__title-input input').fill('Plan the returnable bottle trial')
  await page.locator('.discussion-form .lmo-textarea div[contenteditable=true]').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('new-discussion', [
      'Several cafes want to trial returnable glass bottles, and each cafe has offered to record returns for six weeks.',
      'We need to compare collection options, cleaning requirements, and transport costs before agreeing on a plan.',
      'Add practical questions, dependencies, and anything cafe staff will need before the trial begins.'
    ]))
  await page.locator('.tags-field__input .v-field').click()
  await expect(page.locator('.v-overlay .v-list-item').first()).toBeVisible()
  await page.evaluate("Array.from(document.querySelectorAll('.v-overlay .v-list-item')).find(el => el.textContent.includes('Sustainability')).click()")
  await page.locator('.tags-field__input .v-field').click()
  await expect(page.locator('.v-overlay .v-list-item').first()).toBeVisible()
  await page.evaluate("Array.from(document.querySelectorAll('.v-overlay .v-list-item')).find(el => el.textContent.includes('Packaging')).click()")
  await page.locator('.discussion-form__title-input input').click()
  await page.evaluate('document.activeElement.blur()')
  await expect(page.locator('.discussion-form__title-input input')).toHaveValue('Plan the returnable bottle trial')
  await screenshot.captureElement('discussions/starting_a_discussion/new-discussion-example', '.discussion-form', {
    height: 1200
  });
});
