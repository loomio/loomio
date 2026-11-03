import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openDirectDiscussions(page) {
  await page.goto('/dev/setup_manual_oatmilk_direct_discussions')
  await expect(page.locator('.topics-page').first()).toBeVisible()
  await expectLabel(page.locator('.topics-page'), 'Cafe bottle collection check-in')
}

test('direct_discussion_example', async ({ page, manual: screenshot }) => {
  await openDirectDiscussions(page);
  await page.locator('.topics-page__new-topic-button').click()
  await page.locator('.discussion-templates--direct-discussion').click()
  await expect(page.locator('.discussion-form').first()).toBeVisible()
  await page.locator('.discussion-form__title-input input').fill('Cafe bottle collection planning')
  await page.locator('.discussion-form .ProseMirror').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('direct-discussion', [
    'Use this direct discussion to confirm collection dates for the six-week bottle trial.',
    'Samira will check washing capacity while Jamie confirms the driver schedule and crate storage.',
    'Record any change that cafe staff need to know before the first delivery.'
  ]))
  await page.locator('.recipients-autocomplete input[type="text"]').fill('Samira')
  await expect(page.locator('.recipients-autocomplete-suggestion').first()).toBeVisible()
  await page.evaluate("Array.from(document.querySelectorAll('.recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Samira Patel')).click()")
  await expectLabel(page.locator('.recipients-autocomplete'), 'Samira Patel')
  await page.locator('.discussion-form__title-input input').click()
  await screenshot.captureElement('discussions/direct_discussions/direct-discussion-example', '.discussion-form', {
    width: 1100,
    height: 1400
  });
});

test('direct_discussion_sidebar', async ({ page, manual: screenshot }) => {
  await openDirectDiscussions(page);
  await page.locator('.navbar__sidenav-toggle').click()
  await screenshot.capture('discussions/direct_discussions/direct-discussion-sidebar', {
    spotlight: {
      selector: '.sidebar__list-item-button--private',
      padding: 10,
      radius: 12
    },
    width: 1280,
    height: 900
  });
});
