import { test, expect } from '../screenshotFixtures.mjs';

async function spotlight(selectors) {
  return {
    selectors,
    padding: 16,
    radius: 20,
    opacity: 0.4,
    outlineWidth: 0
  };
}

test('process_run', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_formatting?key=0');
  await page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
  await page.expectText('.decision-tools-card__poll-types', 'Sense check');
  await screenshot.captureElement(
    'polls/intro_to_decisions/process_run',
    '.actions-panel',
    {width: 1280, height: 1000}
  );
});

test('standalone_poll', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.clickAndWait('.group-page-polls-tab', '.polls-panel__new-poll-button');
  await page.expectText('.polls-panel__new-poll-button', 'New poll');
  await screenshot.capture('polls/intro_to_decisions/standalone_poll', {
    width: 1280,
    height: 900,
    spotlight: spotlight(['.group-page-polls-tab', '.polls-panel__new-poll-button'])
  });
});
