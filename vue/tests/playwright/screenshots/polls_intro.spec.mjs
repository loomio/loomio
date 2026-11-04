import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

function spotlight(selectors) {
  return {
    selectors,
    padding: 16,
    radius: 20,
    opacity: 0.4,
    outlineWidth: 0
  };
}

test('process_run', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_formatting?key=0')
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers')
  await page.locator('.activity-panel__add-poll').click()
  await expectLabel(page.locator('.decision-tools-card__poll-types'), 'Sense check')
  await screenshot.captureElement(
    'polls/intro_to_decisions/process_run',
    '.actions-panel',
    {width: 1280, height: 1000}
  );
});

test('standalone_poll', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page-polls-tab').click()
  await expectLabel(page.locator('.polls-panel__new-poll-button'), 'New poll')
  await screenshot.capture('polls/intro_to_decisions/standalone_poll', {
    width: 1280,
    height: 757,
    spotlight: spotlight(['.group-page-polls-tab', '.polls-panel__new-poll-button'])
  });
});
