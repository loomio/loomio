const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

module.exports = {
  '@tags': ['manual-screenshot'],

  'member_weights': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_vote_weights?view=group');
    page.click('.group-page-members-tab');
    page.waitFor('.members-panel__edit-weights');
    page.clickAndWait('.members-panel__edit-weights', '.member-weights-page');
    page.expectText('.member-weights-page', 'Jamie Chen');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    screenshot.captureElement('polls/weighted_voting/member-weights', '.group-page', {
      width: 1200,
      height: 1400,
      spotlight: {selector: '.member-weights-page', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
    });
  },

  'poll_setting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_vote_weights?view=edit');
    page.clickAndWait('.poll-common-form__more-settings', '.poll-settings-weighted-voting');
    page.expectText('.poll-settings-weighted-voting', 'Use weighted voting');
    screenshot.captureRegion('polls/weighted_voting/poll-setting', ['.poll-common-form__more-settings', '.poll-common-form__reminder-title'], {
      padding: 32,
      width: 1200,
      height: 1200,
      scrollSelector: '.poll-settings-weighted-voting',
      spotlight: {selectors: ['.text-body-large:has(+ .text-body-medium + .poll-settings-weighted-voting)', '.poll-settings-weighted-voting'], padding: 16, radius: 14, opacity: 0.4, outlineWidth: 0}
    });
  },

  'poll_manage_voters': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_vote_weights?votes=1');
    page.waitFor('.poll-created .action-dock__button--announce_poll');
    page.expectText('.poll-created .action-dock__button--announce_poll', 'Manage voters');
    screenshot.captureRegion('polls/weighted_voting/poll-manage-voters', ['.poll-created .poll-common-card__title', '.poll-created .action-dock'], {
      padding: 24,
      width: 1200,
      height: 1400,
      clearSelection: true,
      spotlight: {selector: '.poll-created .action-dock__button--announce_poll', padding: 10, radius: 14, opacity: 0.4, outlineWidth: 0}
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
    screenshot.captureRegion('polls/weighted_voting/weighted-proposal-result', ['.poll-created .poll-common-card__title', '.poll-created .poll-common-chart-panel'], {
      padding: 24,
      width: 1200,
      height: 1400,
      clearSelection: true,
      spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
    });
    page.click('.poll-common-chart-table thead th:nth-child(3) button');
    page.expectElement('.poll-common-chart-table thead th:nth-child(3) button[aria-pressed="true"]');
    page.expectText('.poll-common-chart-table', '67%');
  }
};
