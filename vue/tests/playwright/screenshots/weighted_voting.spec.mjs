import { test, expect } from '../screenshotFixtures.mjs';

test('member_weights', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_vote_weights?view=group');
  await page.click('.group-page-members-tab');
  await page.waitFor('.members-panel__edit-weights');
  await page.clickAndWait('.members-panel__edit-weights', '.member-weights-page');
  await page.expectText('.member-weights-page', 'Jamie Chen');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await screenshot.captureElement('polls/weighted_voting/member-weights', '.group-page', {
    width: 1200,
    height: 1400,
    spotlight: {selector: '.member-weights-page', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
  });
});

test('poll_setting', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_vote_weights?view=edit');
  await page.clickAndWait('.poll-common-form__more-settings', '.poll-settings-weighted-voting');
  await page.expectText('.poll-settings-weighted-voting', 'Use weighted voting');
  await page.expectText('.poll-common-form__quorum', 'Quorum');
  await screenshot.captureRegion('polls/weighted_voting/poll-setting', ['.poll-common-form__more-settings', '.poll-common-form__quorum + .text-body-medium'], {
    padding: 16,
    width: 1200,
    height: 1400,
    scrollSelector: '.poll-settings-weighted-voting',
    spotlight: {selectors: ['.text-body-large:has(+ .text-body-medium + .poll-settings-weighted-voting)', '.poll-settings-weighted-voting'], padding: 16, radius: 14, opacity: 0.4, outlineWidth: 0}
  });
});

test('poll_manage_voters', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_vote_weights?votes=partial');
  await page.waitFor('.poll-created .action-dock__button--announce_poll');
  await page.expectText('.poll-created .action-dock__button--announce_poll', 'Manage voters');
  await screenshot.captureElement('polls/weighted_voting/poll-manage-voters', '.poll-created', {
    width: 1600,
    height: 1400,
    clearSelection: true,
    spotlight: {selector: '.poll-created .action-dock__button--announce_poll', padding: 10, radius: 14, opacity: 0.4, outlineWidth: 0}
  });
});

test('poll_voter_weights', async ({ lmo: page, manual: screenshot }) => {
  await page.resizeWindow(1200, 800);
  await page.loadPath('setup_manual_oatmilk_vote_weights?votes=partial');
  await page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form__list');
  await page.expectText('.poll-members-form__list', 'Jamie Chen');
  await page.expectText('.poll-members-form__list', 'Samira Patel');
  await page.expectText('.poll-members-form__list', 'Alex Morgan');
  await screenshot.captureElement('polls/weighted_voting/poll-voter-weights', '.poll-members-form', {width: 1200, height: 800});
});

test('weighted_proposal_result', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_vote_weights?votes=partial');
  await page.waitFor('.poll-created .poll-common-chart-panel');
  await page.expectText('.poll-common-chart-panel', 'Agree');
  await page.expectText('.poll-common-chart-panel', 'Disagree');
  await page.expectText('.poll-common-chart-table tbody tr:last-child', 'Not voted');
  await page.expectText('.poll-common-chart-table tbody tr:first-child td:nth-child(4)', '2');
  await page.expectText('.poll-common-chart-table tbody tr:first-child td:nth-child(6)', '67%');
  await page.expectText('.poll-common-chart-table tbody tr:last-child td:nth-child(3)', '3');
  await page.expectText('.poll-created .poll-common-chart-panel', '50% of vote weight');
  await page.expectText('.poll-created .poll-common-chart-panel', '60% of eligible vote weight must participate');
  await screenshot.captureElement('polls/weighted_voting/weighted-proposal-result', '.poll-created', {
    width: 1600,
    height: 1400,
    clearSelection: true,
    spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
  });
  await page.click('.poll-common-chart-table thead th:nth-child(3) button');
  await page.expectElement('.poll-common-chart-table thead th:nth-child(3) button[aria-pressed="true"]');
  await page.expectText('.poll-created .poll-common-chart-panel', '66% participation');
});
