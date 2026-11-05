import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function openDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion');
  await expect(page.locator('.context-panel')).toBeVisible();
}

async function openAdviceDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_advice_discussion');
  // Wait for the comments to load; any one will do.
  await expect(page.locator('.new-comment').first()).toBeVisible();
  await expectLabel(page.locator('.topic-card'), 'updated comparison after the warehouse visit');
}

async function openPoll(page, template, mode) {
  await page.goto(`/dev/setup_manual_oatmilk_proposal_template_poll?template=${template}${mode ? `&mode=${mode}` : ''}`);
  await expect(page.locator('.poll-common-card__title')).toBeVisible();
  if (mode === 'outcome') { await expect(page.locator('.poll-common-outcome-panel')).toBeVisible(); }
}

async function captureDiscussion(screenshot, name, selector = '.topic-card') {
  await screenshot.captureElement(`guides/making_decisions/${name}`, selector, { width: 1280, height: 2000 });
}

async function capturePoll(screenshot, name, mode = 'voting') {
  const selectors = mode === 'outcome'
    ? ['.poll-common-card__title', '.poll-common-outcome-panel']
    : ['.poll-common-card__title', '.poll-common-action-panel'];
  await screenshot.captureRegion(`guides/making_decisions/${name}`, selectors, {
    width: 1100,
    height: 2300,
    padding: 16
  });
}

// The thread context shown at the start of each guide.
for (const name of [
  'discussion_takashi_computer',
  'discussion_consensus_process_refresh_brand',
  'discussion_context_health_and_safety',
  'discussion_simple_decision_refresh_brand',
]) {
  test(name, async ({ page, manual: screenshot }) => {
    await openDiscussion(page);
    await captureDiscussion(screenshot, name, '.context-panel');
  });
}

test('discussion_comments_advice_process_new_computer', async ({ page, manual: screenshot }) => {
  await openAdviceDiscussion(page);
  await captureDiscussion(screenshot, 'discussion_comments_advice_process_new_computer', '.topic-card');
});

test('proposal_reply_health_and_safety', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  // Wait for the comments to load; any one will do.
  await expect(page.locator('.new-comment').first()).toBeVisible();
  await captureDiscussion(screenshot, 'proposal_reply_health_and_safety', '.topic-card');
});

// Each proposal from a template, while voting or with its outcome.
for (const [name, template, mode] of [
  ['decision_outcome_advice_process_new_computer', 'advice', 'outcome'],
  ['proposal_sense_check_refresh_brand', 'check'],
  ['proposal_outcome_sense_check_refresh_brand', 'check', 'outcome'],
  ['proposal_consensus_process_refresh_brand', 'consensus'],
  ['proposal_vote_consensus_process_refresh_brand', 'consensus'],
  ['proposal_outcome_consensus_process_refresh_brand', 'consensus', 'outcome'],
  ['proposal_question_health_and_safety', 'question'],
  ['proposal_reaction_round_health_and_safety', 'check'],
  ['proposal_outcome_reaction_round_health_and_safety', 'check', 'outcome'],
  ['proposal_consent_process_health_and_safety', 'consent'],
  ['proposal_outcome_consent_process_health_and_safety', 'consent', 'outcome'],
  ['proposal_sense_check_simple_process_refresh_brand', 'check'],
  ['proposal_consent_simple_process_refresh_brand', 'consent'],
  ['proposal_outcome_simple_process_refresh_brand', 'consent', 'outcome'],
]) {
  test(name, async ({ page, manual: screenshot }) => {
    await openPoll(page, template, mode);
    await capturePoll(screenshot, name, mode);
  });
}
