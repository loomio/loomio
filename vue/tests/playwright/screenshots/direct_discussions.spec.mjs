import { test, expect } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openDirectDiscussions(page) {
  await page.loadPath('setup_manual_oatmilk_direct_discussions');
  await page.waitFor('.topics-page');
  await page.expectText('.topics-page', 'Cafe bottle collection check-in');
}

test('direct_discussion_example', async ({ lmo: page, manual: screenshot }) => {
  await openDirectDiscussions(page);
  await page.click('.topics-page__new-topic-button');
  await page.waitFor('.discussion-templates--direct-discussion');
  await page.click('.discussion-templates--direct-discussion');
  await page.waitFor('.discussion-form');
  await page.fillIn('.discussion-form__title-input input', 'Cafe bottle collection planning');
  await page.fillRichText('.discussion-form .ProseMirror', richText.context('direct-discussion', [
    'Use this direct discussion to confirm collection dates for the six-week bottle trial.',
    'Samira will check washing capacity while Jamie confirms the driver schedule and crate storage.',
    'Record any change that cafe staff need to know before the first delivery.'
  ]));
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'Samira');
  await page.waitFor('.recipients-autocomplete-suggestion');
  await page.execute("Array.from(document.querySelectorAll('.recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Samira Patel')).click()");
  await page.expectText('.recipients-autocomplete', 'Samira Patel');
  await page.click('.discussion-form__title-input input');
  await screenshot.captureElement('discussions/direct_discussions/direct-discussion-example', '.discussion-form', {
    width: 1100,
    height: 1400
  });
});

test('direct_discussion_sidebar', async ({ lmo: page, manual: screenshot }) => {
  await openDirectDiscussions(page);
  await page.ensureSidebar();
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
