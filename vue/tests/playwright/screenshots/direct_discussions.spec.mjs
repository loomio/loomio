import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';
import { editor } from '../helpers/editor.mjs';
import { addRecipient } from '../helpers/recipients.mjs';
import { ensureSidebar } from '../helpers/groups.mjs';

async function openDirectDiscussions(page) {
  await page.goto('/dev/setup_manual_oatmilk_direct_discussions')
  await expectLabel(page.locator('.topics-page'), 'Cafe bottle collection check-in')
}

test('direct_discussion_example', async ({ page, manual: screenshot }) => {
  await openDirectDiscussions(page);
  await page.locator('.topics-page__new-topic-button').click()
  await page.locator('.topics-page__new-discussion-button').click()
  await page.locator('.discussion-templates--direct-discussion').click()
  const form = page.locator('.discussion-form')
  await form.locator('.discussion-form__title-input input').fill('Cafe bottle collection planning')
  await editor(form).evaluate((element, html) => {
    element.focus()
    element.innerHTML = html
    element.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('direct-discussion', [
    'Use this direct discussion to confirm collection dates for the six-week bottle trial.',
    'Samira will check washing capacity while Jamie confirms the driver schedule and crate storage.',
    'Record any change that cafe staff need to know before the first delivery.'
  ]))
  await addRecipient(page, 'Samira', 'Samira Patel')
  await expectLabel(page.locator('.recipients-autocomplete'), 'Samira Patel')
  await form.locator('.discussion-form__title-input input').click()
  await screenshot.captureElement('discussions/direct_discussions/direct-discussion-example', '.discussion-form', {
    width: 1100,
    height: 1400
  });
});

test('direct_discussion_sidebar', async ({ page, manual: screenshot }) => {
  await openDirectDiscussions(page);
  await ensureSidebar(page)
  await screenshot.capture('discussions/direct_discussions/direct-discussion-sidebar', {
    spotlight: {
      selector: '.sidebar__list-item-button--private',
      padding: 10,
      radius: 12
    },
    width: 1280,
    height: 757
  });
});
