import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function openDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expect(page.locator('.context-panel').first()).toBeVisible()
}

async function openAdviceDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_advice_discussion')
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expect(page.locator('.new-comment').first()).toBeVisible()
  await expectLabel(page.locator('.topic-card'), 'updated comparison after the warehouse visit')
}

async function openPoll(page, template, mode) {
  await page.goto(`/dev/setup_manual_oatmilk_proposal_template_poll?template=${template}${mode ? `&mode=${mode}` : ''}`)
  await expect(page.locator('.poll-common-card__title').first()).toBeVisible()
}

async function captureDiscussion(screenshot, name, selector = '.topic-card') {
  await screenshot.captureElement(`guides/making_decisions/${name}`, selector, {width: 1280, height: 2000});
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

test('discussion_takashi_computer', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await captureDiscussion(screenshot, 'discussion_takashi_computer', '.context-panel');
});
test('discussion_comments_advice_process_new_computer', async ({ page, manual: screenshot }) => {
  await openAdviceDiscussion(page);
  await captureDiscussion(screenshot, 'discussion_comments_advice_process_new_computer', '.topic-card');
});
test('decision_outcome_advice_process_new_computer', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'advice', 'outcome');
  await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible();
  await capturePoll(screenshot, 'decision_outcome_advice_process_new_computer', 'outcome');
});

test('discussion_consensus_process_refresh_brand', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await captureDiscussion(screenshot, 'discussion_consensus_process_refresh_brand', '.context-panel');
});
test('proposal_sense_check_refresh_brand', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'check');
  await capturePoll(screenshot, 'proposal_sense_check_refresh_brand');
});
test('proposal_outcome_sense_check_refresh_brand', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'check', 'outcome');
  await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible();
  await capturePoll(screenshot, 'proposal_outcome_sense_check_refresh_brand', 'outcome');
});
test('proposal_consensus_process_refresh_brand', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'consensus');
  await capturePoll(screenshot, 'proposal_consensus_process_refresh_brand');
});
test('proposal_vote_consensus_process_refresh_brand', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'consensus');
  await capturePoll(screenshot, 'proposal_vote_consensus_process_refresh_brand');
});
test('proposal_outcome_consensus_process_refresh_brand', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'consensus', 'outcome');
  await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible();
  await capturePoll(screenshot, 'proposal_outcome_consensus_process_refresh_brand', 'outcome');
});

test('discussion_context_health_and_safety', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await captureDiscussion(screenshot, 'discussion_context_health_and_safety', '.context-panel');
});
test('proposal_question_health_and_safety', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'question');
  await capturePoll(screenshot, 'proposal_question_health_and_safety');
});
test('proposal_reply_health_and_safety', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await expect(page.locator('.new-comment').first()).toBeVisible();
  await captureDiscussion(screenshot, 'proposal_reply_health_and_safety', '.topic-card');
});
test('proposal_reaction_round_health_and_safety', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'check');
  await capturePoll(screenshot, 'proposal_reaction_round_health_and_safety');
});
test('proposal_outcome_reaction_round_health_and_safety', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'check', 'outcome');
  await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible();
  await capturePoll(screenshot, 'proposal_outcome_reaction_round_health_and_safety', 'outcome');
});
test('proposal_consent_process_health_and_safety', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'consent');
  await capturePoll(screenshot, 'proposal_consent_process_health_and_safety');
});
test('proposal_outcome_consent_process_health_and_safety', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'consent', 'outcome');
  await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible();
  await capturePoll(screenshot, 'proposal_outcome_consent_process_health_and_safety', 'outcome');
});

test('discussion_simple_decision_refresh_brand', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await captureDiscussion(screenshot, 'discussion_simple_decision_refresh_brand', '.context-panel');
});
test('proposal_sense_check_simple_process_refresh_brand', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'check');
  await capturePoll(screenshot, 'proposal_sense_check_simple_process_refresh_brand');
});
test('proposal_consent_simple_process_refresh_brand', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'consent');
  await capturePoll(screenshot, 'proposal_consent_simple_process_refresh_brand');
});
test('proposal_outcome_simple_process_refresh_brand', async ({ page, manual: screenshot }) => {
  await openPoll(page, 'consent', 'outcome');
  await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible();
  await capturePoll(screenshot, 'proposal_outcome_simple_process_refresh_brand', 'outcome');
});
