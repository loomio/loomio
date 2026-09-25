const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  'group_permission': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_vote_weights?view=group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page .action-menu--btn');
    page.waitFor('.v-overlay .action-dock__button--edit_group');
    page.click('.v-overlay .action-dock__button--edit_group');
    page.waitFor('.group-form');
    page.click('.group-form__permissions-tab');
    page.expectText('.group-form__vote-weights-allowed', 'Allow vote weights');
    screenshot.captureElement('polls/weighted_voting/group-permission', '.group-form', {
      width: 1200,
      height: 1400,
      spotlight: {selector: '.group-form__vote-weights-allowed', padding: 14, radius: 14, opacity: 0.4, outlineWidth: 0}
    });
  },

  'member_weights': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_vote_weights?view=group');
    page.click('.group-page-members-tab');
    page.waitFor('.members-panel__edit-weights');
    page.clickAndWait('.members-panel__edit-weights', '.member-weights-page');
    page.expectText('.member-weights-page', 'Jamie Chen');
    screenshot.captureElement('polls/weighted_voting/member-weights', '.member-weights-page', {width: 1200, height: 1000});
  },

  'poll_setting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_vote_weights?view=edit');
    page.clickAndWait('.poll-common-form__more-settings', '.poll-settings-vote-weights');
    page.expectText('.poll-settings-vote-weights', 'Use vote weights');
    screenshot.captureRegion('polls/weighted_voting/poll-setting', ['.poll-settings-vote-weights'], {
      padding: 24,
      width: 1200,
      height: 900,
      scrollSelector: '.poll-settings-vote-weights'
    });
  },

  'poll_voter_weights': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_vote_weights?votes=1');
    page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form__list');
    page.expectText('.poll-members-form__list', 'Jamie Chen');
    page.expectText('.poll-members-form__list', 'Samira Patel');
    page.expectText('.poll-members-form__list', 'Alex Morgan');
    screenshot.captureElement('polls/weighted_voting/poll-voter-weights', '.poll-members-form', {width: 1200, height: 700});
  },

  'weighted_proposal_result': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_vote_weights?votes=1');
    page.waitFor('.poll-created .poll-common-chart-panel');
    page.expectText('.poll-common-chart-panel', 'Agree');
    page.expectText('.poll-common-chart-panel', 'Disagree');
    screenshot.captureElement('polls/weighted_voting/weighted-proposal-result', '.poll-created .poll-common-chart-panel', {width: 1200, height: 1000});
  }
};
