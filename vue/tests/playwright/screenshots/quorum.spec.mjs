import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openProposalForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_formatting?key=0')
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers')
  await page.locator('.activity-panel__add-poll').click()
  await expectLabel(page.locator('.decision-tools-card__poll-types'), 'Consent')
  await page.locator('.decision-tools-card__template--consent').click()
  await page.locator('.poll-common-form-fields__title input').fill('Approve the returnable bottle trial budget')
  await page.locator('.poll-common-form-fields__details [contenteditable=true]').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('quorum-proposal', [
      'Approve the bottle deposits, washing costs, and collection budget for the six-week trial.',
      'The budget covers three cafe partners, weekly collections, replacement bottles, and batch records.',
      'Review the figures before voting and explain any cost that should be adjusted.'
    ]))
}

async function openQuorumPoll(page, votes) {
  await page.goto(`/dev/setup_manual_oatmilk_quorum?votes=${votes}`)
  await expect(page.locator('.poll-created .poll-common-chart-panel').first()).toBeVisible()
  await expectLabel(page.locator('.poll-created'), 'Run a six-week returnable bottle trial')
  await expectLabel(page.locator('.poll-created'), `${votes} of 5 votes cast (${votes * 20}% participation)`)
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
  await page.locator('.poll-common-form__quorum-title ~ .v-number-input input').fill('60')
  await page.evaluate(`
    const title = document.querySelector('.poll-common-form__quorum-title');
    title.classList.add('manual-quorum-title');
    title.nextElementSibling.classList.add('manual-quorum-hint');
    title.nextElementSibling.nextElementSibling.classList.add('manual-quorum-input');
    title.nextElementSibling.nextElementSibling.nextElementSibling.classList.add('manual-quorum-tip');
    title.scrollIntoView({block: 'center'});
  `)
  await expectLabel(page.locator('.poll-common-form__quorum'), 'Quorum')
  await screenshot.captureRegion(
    'polls/quorum/quorum-section',
    ['.poll-common-form__more-settings', '.manual-quorum-tip'],
    {padding: 16, width: 1200, height: 1400, scrollSelector: '.manual-quorum-title', spotlight: {selectors: ['.manual-quorum-title', '.manual-quorum-hint', '.manual-quorum-input', '.manual-quorum-tip'], padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
  );
});

test('pie_chart_0', async ({ page, manual: screenshot }) => {
  await openQuorumPoll(page, 0);
  await screenshot.captureRegion(
    'polls/quorum/pie-chart-0',
    ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
    {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
  );
});

test('pie_chart_40', async ({ page, manual: screenshot }) => {
  await openQuorumPoll(page, 2);
  await screenshot.captureRegion(
    'polls/quorum/pie-chart-40',
    ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
    {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
  );
});

test('pie_chart_60', async ({ page, manual: screenshot }) => {
  await openQuorumPoll(page, 3);
  await screenshot.captureRegion(
    'polls/quorum/pie-chart-60',
    ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
    {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
  );
});
