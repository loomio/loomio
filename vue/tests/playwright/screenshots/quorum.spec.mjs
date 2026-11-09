import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import richText, { fillRichText } from '../helpers/oatmilkRichText.mjs';

async function openProposalForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_formatting?key=0')
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers')
  await page.locator('.activity-panel__add-poll').click()
  await expectLabel(page.locator('.decision-tools-card__poll-types'), 'Consent')
  await page.locator('.decision-tools-card__template--consent').click()
  await page.locator('.poll-common-form-fields__title input').fill('Approve the returnable bottle trial budget')
  await fillRichText(editor(page.locator('.poll-common-form-fields__details')), richText.context('quorum-proposal', [
    'Approve the bottle deposits, washing costs, and collection budget for the six-week trial.',
    'The budget covers three cafe partners, weekly collections, replacement bottles, and batch records.',
    'Review the figures before voting and explain any cost that should be adjusted.'
  ]))
}

async function openQuorumPoll(page, votes) {
  await page.goto(`/dev/setup_manual_oatmilk_quorum?votes=${votes}`)
  await expect(page.locator('.poll-created .poll-common-chart-panel')).toBeVisible()
  await expectLabel(page.locator('.poll-created'), 'Run a six-week returnable bottle trial')
  await expectLabel(page.locator('.poll-created'), `${votes} of 5 votes cast (${votes * 20}% participation)`)
}

const chartSpotlight = {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0};

async function capturePieChart(screenshot, name) {
  await screenshot.captureRegion(
    `polls/quorum/${name}`,
    ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
    {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: chartSpotlight}
  );
}

test('proposal_options', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1200, height: 2000 })
  await openProposalForm(page);
  await screenshot.captureRegion(
    'polls/quorum/proposal-options',
    ['.poll-common-form > .v-card-title', '.poll-common-form__voters-heading + .v-input'],
    {padding: 0, width: 1200, height: 2000, clearSelection: true, scrollSelector: '.poll-common-form > .v-card-title', scrollBlock: 'start'}
  );
});

test('quorum_section', async ({ page, manual: screenshot }) => {
  await openProposalForm(page);
  await page.locator('.poll-common-form__more-settings').click()
  await page.locator('.poll-common-form__quorum input').fill('60')
  await expect(page.locator('.poll-common-form__quorum-tip')).toBeVisible()
  await expectLabel(page.locator('.poll-common-form__quorum'), 'Quorum')
  await screenshot.captureRegion(
    'polls/quorum/quorum-section',
    ['.poll-common-form__more-settings', '.poll-common-form__quorum-tip'],
    {padding: 16, width: 1200, height: 1400, scrollSelector: '.poll-common-form__quorum-title', spotlight: {selectors: ['.poll-common-form__quorum-title', '.poll-common-form__quorum-hint', '.poll-common-form__quorum', '.poll-common-form__quorum-tip'], padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
  );
});

test('pie_chart_0', async ({ page, manual: screenshot }) => {
  await openQuorumPoll(page, 0);
  await capturePieChart(screenshot, 'pie-chart-0');
});

test('pie_chart_40', async ({ page, manual: screenshot }) => {
  await openQuorumPoll(page, 2);
  await capturePieChart(screenshot, 'pie-chart-40');
});

test('pie_chart_60', async ({ page, manual: screenshot }) => {
  await openQuorumPoll(page, 3);
  await capturePieChart(screenshot, 'pie-chart-60');
});
