import { test, expect } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openProposalForm(page) {
  await page.loadPath('setup_manual_oatmilk_formatting?key=0');
  await page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
  await page.expectText('.decision-tools-card__poll-types', 'Consent');
  await page.click('.decision-tools-card__template--consent');
  await page.waitFor('.poll-common-form-fields__title input');
  await page.fillIn('.poll-common-form-fields__title input', 'Approve the returnable bottle trial budget');
  await page.fillRichText(
    '.poll-common-form-fields__details [contenteditable=true]',
    richText.context('quorum-proposal', [
      'Approve the bottle deposits, washing costs, and collection budget for the six-week trial.',
      'The budget covers three cafe partners, weekly collections, replacement bottles, and batch records.',
      'Review the figures before voting and explain any cost that should be adjusted.'
    ])
  );
}

async function openQuorumPoll(page, votes) {
  await page.loadPath(`setup_manual_oatmilk_quorum?votes=${votes}`);
  await page.waitFor('.poll-created .poll-common-chart-panel');
  await page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
  await page.expectText('.poll-created', `${votes} of 5 votes cast (${votes * 20}% participation)`);
  await page.pause(400);
}

test('proposal_options', async ({ lmo: page, manual: screenshot }) => {
  await page.resizeWindow(1200, 2000);
  await openProposalForm(page);
  await screenshot.captureRegion(
    'polls/quorum/proposal-options',
    ['.poll-common-form > .v-card-title', '.poll-common-form__voters-heading + .v-input'],
    {padding: 0, width: 1200, height: 2000, clearSelection: true, scrollSelector: '.poll-common-form > .v-card-title', scrollBlock: 'start'}
  );
});

test('quorum_section', async ({ lmo: page, manual: screenshot }) => {
  await openProposalForm(page);
  await page.clickAndWait('.poll-common-form__more-settings', '.poll-common-form__quorum-title');
  await page.fillIn('.poll-common-form__quorum-title ~ .v-number-input input', '60');
  await page.execute(`
    const title = document.querySelector('.poll-common-form__quorum-title');
    title.classList.add('manual-quorum-title');
    title.nextElementSibling.classList.add('manual-quorum-hint');
    title.nextElementSibling.nextElementSibling.classList.add('manual-quorum-input');
    title.nextElementSibling.nextElementSibling.nextElementSibling.classList.add('manual-quorum-tip');
    title.scrollIntoView({block: 'center'});
  `);
  await page.pause(200);
  await page.expectText('.poll-common-form__quorum', 'Quorum');
  await screenshot.captureRegion(
    'polls/quorum/quorum-section',
    ['.poll-common-form__more-settings', '.manual-quorum-tip'],
    {padding: 16, width: 1200, height: 1400, scrollSelector: '.manual-quorum-title', spotlight: {selectors: ['.manual-quorum-title', '.manual-quorum-hint', '.manual-quorum-input', '.manual-quorum-tip'], padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
  );
});

test('pie_chart_0', async ({ lmo: page, manual: screenshot }) => {
  await openQuorumPoll(page, 0);
  await screenshot.captureRegion(
    'polls/quorum/pie-chart-0',
    ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
    {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
  );
});

test('pie_chart_40', async ({ lmo: page, manual: screenshot }) => {
  await openQuorumPoll(page, 2);
  await screenshot.captureRegion(
    'polls/quorum/pie-chart-40',
    ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
    {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
  );
});

test('pie_chart_60', async ({ lmo: page, manual: screenshot }) => {
  await openQuorumPoll(page, 3);
  await screenshot.captureRegion(
    'polls/quorum/pie-chart-60',
    ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
    {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
  );
});
