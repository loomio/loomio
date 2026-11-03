import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

test('member_weights', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_vote_weights?view=group')
  await page.locator('.group-page-members-tab').click()
  await page.locator('.members-panel__edit-weights').click()
  await expectLabel(page.locator('.member-weights-page'), 'Jamie Chen')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await screenshot.captureElement('polls/weighted_voting/member-weights', '.group-page', {
    width: 1200,
    height: 1400,
    spotlight: {selector: '.member-weights-page', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
  });
});

test('poll_setting', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_vote_weights?view=edit')
  await page.locator('.poll-common-form__more-settings').click()
  await expectLabel(page.locator('.poll-settings-weighted-voting'), 'Use weighted voting')
  await expectLabel(page.locator('.poll-common-form__quorum'), 'Quorum')
  await screenshot.captureRegion('polls/weighted_voting/poll-setting', ['.poll-common-form__more-settings', '.poll-common-form__quorum + .text-body-medium'], {
    padding: 16,
    width: 1200,
    height: 1400,
    scrollSelector: '.poll-settings-weighted-voting',
    spotlight: {selectors: ['.text-body-large:has(+ .text-body-medium + .poll-settings-weighted-voting)', '.poll-settings-weighted-voting'], padding: 16, radius: 14, opacity: 0.4, outlineWidth: 0}
  });
});

test('poll_manage_voters', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_vote_weights?votes=partial')
  await expect(page.locator('.poll-created .action-dock__button--announce_poll').first()).toBeVisible()
  await expectLabel(page.locator('.poll-created .action-dock__button--announce_poll'), 'Manage voters')
  await screenshot.captureElement('polls/weighted_voting/poll-manage-voters', '.poll-created', {
    width: 1600,
    height: 1400,
    clearSelection: true,
    spotlight: {selector: '.poll-created .action-dock__button--announce_poll', padding: 10, radius: 14, opacity: 0.4, outlineWidth: 0}
  });
});

test('poll_voter_weights', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1200, height: 800 })
  await page.goto('/dev/setup_manual_oatmilk_vote_weights?votes=partial')
  await page.locator('.action-dock__button--announce_poll').click()
  await expectLabel(page.locator('.poll-members-form__list'), 'Jamie Chen')
  await expectLabel(page.locator('.poll-members-form__list'), 'Samira Patel')
  await expectLabel(page.locator('.poll-members-form__list'), 'Alex Morgan')
  await screenshot.captureElement('polls/weighted_voting/poll-voter-weights', '.poll-members-form', {width: 1200, height: 800});
});

test('weighted_proposal_result', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_vote_weights?votes=partial')
  await expect(page.locator('.poll-created .poll-common-chart-panel').first()).toBeVisible()
  await expectLabel(page.locator('.poll-common-chart-panel'), 'Agree')
  await expectLabel(page.locator('.poll-common-chart-panel'), 'Disagree')
  await expectLabel(page.locator('.poll-common-chart-table tbody tr:last-child'), 'Not voted')
  await expectLabel(page.locator('.poll-common-chart-table tbody tr:first-child td:nth-child(4)'), '2')
  await expectLabel(page.locator('.poll-common-chart-table tbody tr:first-child td:nth-child(6)'), '67%')
  await expectLabel(page.locator('.poll-common-chart-table tbody tr:last-child td:nth-child(3)'), '3')
  await expectLabel(page.locator('.poll-created .poll-common-chart-panel'), '50% of vote weight')
  await expectLabel(page.locator('.poll-created .poll-common-chart-panel'), '60% of eligible vote weight must participate')
  await screenshot.captureElement('polls/weighted_voting/weighted-proposal-result', '.poll-created', {
    width: 1600,
    height: 1400,
    clearSelection: true,
    spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
  });
  await page.locator('.poll-common-chart-table thead th:nth-child(3) button').click()
  await expect(page.locator('.poll-common-chart-table thead th:nth-child(3) button[aria-pressed="true"]').first()).toBeVisible()
  await expectLabel(page.locator('.poll-created .poll-common-chart-panel'), '66% participation')
});
