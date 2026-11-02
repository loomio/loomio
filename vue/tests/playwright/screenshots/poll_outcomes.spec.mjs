import { test, expect } from '../screenshotFixtures.mjs';

async function openOutcome(page, published = false) {
  await page.loadPath(`setup_manual_oatmilk_outcome${published ? '?published=1' : ''}`);
  await page.waitFor('.poll-created');
  await page.expectText('.poll-common-card__title', 'Run a six-week returnable bottle trial');
}

test('outcome_prompt', async ({ lmo: page, manual: screenshot }) => {
  await openOutcome(page);
  await page.waitFor('.poll-common-set-outcome-panel');
  await screenshot.captureRegion(
    'polls/intro_to_decisions/outcome_prompt',
    ['.poll-created .poll-common-card__title', '.poll-created .poll-common-chart-panel', '.poll-created .action-dock'],
    {
      padding: 32,
      width: 1200,
      height: 1800,
      clearSelection: true,
      spotlight: {selector: '.poll-common-set-outcome-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
    }
  );
});

test('outcome_published', async ({ lmo: page, manual: screenshot }) => {
  await openOutcome(page, true);
  await page.waitFor('.poll-common-outcome-panel');
  await page.expectText('.poll-common-outcome-panel', 'Jamie will confirm the cafe collection schedule');
  await screenshot.captureRegion(
    'polls/intro_to_decisions/outcome_published',
    ['.poll-created .poll-common-card__title', '.poll-created .poll-common-chart-panel', '.poll-created .action-dock'],
    {
      padding: 32,
      width: 1200,
      height: 1800,
      clearSelection: true,
      spotlight: {selector: '.poll-common-outcome-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
    }
  );
});
