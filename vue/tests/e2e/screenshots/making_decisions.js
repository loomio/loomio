const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_discussion');
  page.waitFor('.topic-page');
  page.waitFor('.context-panel');
}

function openAdviceDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_advice_discussion');
  page.waitFor('.topic-page');
  page.waitFor('.new-comment');
  page.expectText('.strand-card', 'updated comparison after the warehouse visit');
}

function openPoll(page, template, mode) {
  page.loadPath(`setup_manual_oatmilk_proposal_template_poll?template=${template}${mode ? `&mode=${mode}` : ''}`);
  page.waitFor('.poll-common-card__title');
}

function captureDiscussion(screenshot, name, selector = '.strand-card') {
  screenshot.captureElement(`guides/making_decisions/${name}`, selector, {width: 1280, height: 2000});
}

function capturePoll(screenshot, name, mode = 'voting') {
  const selectors = mode === 'outcome'
    ? ['.poll-common-card__title', '.poll-common-outcome-panel']
    : ['.poll-common-card__title', '.poll-common-action-panel'];
  screenshot.captureRegion(`guides/making_decisions/${name}`, selectors, {
    width: 1100,
    height: 2300,
    padding: 16
  });
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'discussion_takashi_computer': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page); captureDiscussion(screenshot, 'discussion_takashi_computer', '.context-panel');
  },
  'discussion_comments_advice_process_new_computer': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openAdviceDiscussion(page); captureDiscussion(screenshot, 'discussion_comments_advice_process_new_computer', '.strand-card');
  },
  'decision_outcome_advice_process_new_computer': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'advice', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'decision_outcome_advice_process_new_computer', 'outcome');
  },

  'discussion_consensus_process_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page); captureDiscussion(screenshot, 'discussion_consensus_process_refresh_brand', '.context-panel');
  },
  'proposal_sense_check_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'check'); capturePoll(screenshot, 'proposal_sense_check_refresh_brand');
  },
  'proposal_outcome_sense_check_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'check', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_sense_check_refresh_brand', 'outcome');
  },
  'proposal_consensus_process_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'consensus'); capturePoll(screenshot, 'proposal_consensus_process_refresh_brand');
  },
  'proposal_vote_consensus_process_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'consensus'); capturePoll(screenshot, 'proposal_vote_consensus_process_refresh_brand');
  },
  'proposal_outcome_consensus_process_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'consensus', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_consensus_process_refresh_brand', 'outcome');
  },

  'discussion_context_health_and_safety': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page); captureDiscussion(screenshot, 'discussion_context_health_and_safety', '.context-panel');
  },
  'proposal_question_health_and_safety': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'question'); capturePoll(screenshot, 'proposal_question_health_and_safety');
  },
  'proposal_reply_health_and_safety': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page); page.waitFor('.new-comment'); captureDiscussion(screenshot, 'proposal_reply_health_and_safety', '.strand-card');
  },
  'proposal_reaction_round_health_and_safety': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'check'); capturePoll(screenshot, 'proposal_reaction_round_health_and_safety');
  },
  'proposal_outcome_reaction_round_health_and_safety': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'check', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_reaction_round_health_and_safety', 'outcome');
  },
  'proposal_consent_process_health_and_safety': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'consent'); capturePoll(screenshot, 'proposal_consent_process_health_and_safety');
  },
  'proposal_outcome_consent_process_health_and_safety': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'consent', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_consent_process_health_and_safety', 'outcome');
  },

  'discussion_simple_decision_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openDiscussion(page); captureDiscussion(screenshot, 'discussion_simple_decision_refresh_brand', '.context-panel');
  },
  'proposal_sense_check_simple_process_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'check'); capturePoll(screenshot, 'proposal_sense_check_simple_process_refresh_brand');
  },
  'proposal_consent_simple_process_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'consent'); capturePoll(screenshot, 'proposal_consent_simple_process_refresh_brand');
  },
  'proposal_outcome_simple_process_refresh_brand': (test) => {
    const page = pageHelper(test); const screenshot = manualScreenshot(test);
    openPoll(page, 'consent', 'outcome'); page.waitFor('.poll-common-outcome-panel'); capturePoll(screenshot, 'proposal_outcome_simple_process_refresh_brand', 'outcome');
  }
};
