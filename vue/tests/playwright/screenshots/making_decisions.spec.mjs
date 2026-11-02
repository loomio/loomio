import { test, expect } from '../screenshotFixtures.mjs';

async function openDiscussion(page) {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.waitFor('.topic-page');
  await page.waitFor('.context-panel');
}

async function openAdviceDiscussion(page) {
  await page.loadPath('setup_manual_oatmilk_advice_discussion');
  await page.waitFor('.topic-page');
  await page.waitFor('.new-comment');
  await page.expectText('.topic-card', 'updated comparison after the warehouse visit');
}

async function openPoll(page, template, mode) {
  await page.loadPath(`setup_manual_oatmilk_proposal_template_poll?template=${template}${mode ? `&mode=${mode}` : ''}`);
  await page.waitFor('.poll-common-card__title');
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

test('discussion_takashi_computer', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page); captureDiscussion(screenshot, 'discussion_takashi_computer', '.context-panel');
});
test('discussion_comments_advice_process_new_computer', async ({ lmo: page, manual: screenshot }) => {
  await openAdviceDiscussion(page); captureDiscussion(screenshot, 'discussion_comments_advice_process_new_computer', '.topic-card');
});
test('decision_outcome_advice_process_new_computer', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'advice', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'decision_outcome_advice_process_new_computer', 'outcome');
});

test('discussion_consensus_process_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page); captureDiscussion(screenshot, 'discussion_consensus_process_refresh_brand', '.context-panel');
});
test('proposal_sense_check_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'check'); capturePoll(screenshot, 'proposal_sense_check_refresh_brand');
});
test('proposal_outcome_sense_check_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'check', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_sense_check_refresh_brand', 'outcome');
});
test('proposal_consensus_process_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'consensus'); capturePoll(screenshot, 'proposal_consensus_process_refresh_brand');
});
test('proposal_vote_consensus_process_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'consensus'); capturePoll(screenshot, 'proposal_vote_consensus_process_refresh_brand');
});
test('proposal_outcome_consensus_process_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'consensus', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_consensus_process_refresh_brand', 'outcome');
});

test('discussion_context_health_and_safety', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page); captureDiscussion(screenshot, 'discussion_context_health_and_safety', '.context-panel');
});
test('proposal_question_health_and_safety', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'question'); capturePoll(screenshot, 'proposal_question_health_and_safety');
});
test('proposal_reply_health_and_safety', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page); page.waitFor('.new-comment'); captureDiscussion(screenshot, 'proposal_reply_health_and_safety', '.topic-card');
});
test('proposal_reaction_round_health_and_safety', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'check'); capturePoll(screenshot, 'proposal_reaction_round_health_and_safety');
});
test('proposal_outcome_reaction_round_health_and_safety', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'check', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_reaction_round_health_and_safety', 'outcome');
});
test('proposal_consent_process_health_and_safety', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'consent'); capturePoll(screenshot, 'proposal_consent_process_health_and_safety');
});
test('proposal_outcome_consent_process_health_and_safety', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'consent', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_consent_process_health_and_safety', 'outcome');
});

test('discussion_simple_decision_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page); captureDiscussion(screenshot, 'discussion_simple_decision_refresh_brand', '.context-panel');
});
test('proposal_sense_check_simple_process_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'check'); capturePoll(screenshot, 'proposal_sense_check_simple_process_refresh_brand');
});
test('proposal_consent_simple_process_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'consent'); capturePoll(screenshot, 'proposal_consent_simple_process_refresh_brand');
});
test('proposal_outcome_simple_process_refresh_brand', async ({ lmo: page, manual: screenshot }) => {
  await openPoll(page, 'consent', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_simple_process_refresh_brand', 'outcome');
});
