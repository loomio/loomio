const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openOutcome(page, published = false) {
  page.loadPath(`setup_manual_oatmilk_outcome${published ? '?published=1' : ''}`);
  page.waitFor('.poll-created');
  page.expectText('.poll-common-card__title', 'Run a six-week returnable bottle trial');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'outcome_prompt': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openOutcome(page);
    page.waitFor('.poll-common-set-outcome-panel');
    screenshot.captureRegion(
      'polls/intro_to_decisions/outcome_prompt',
      ['.poll-created .poll-common-card__title', '.poll-created .poll-common-chart-panel', '.poll-created .action-dock'],
      {
        padding: 32,
        width: 1200,
        height: 1800,
        clearSelection: true,
        spotlight: {selector: '.poll-common-set-outcome-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
      }
    );
  },

  'outcome_published': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openOutcome(page, true);
    page.waitFor('.poll-common-outcome-panel');
    page.expectText('.poll-common-outcome-panel', 'Jamie will confirm the cafe collection schedule');
    screenshot.captureRegion(
      'polls/intro_to_decisions/outcome_published',
      ['.poll-created .poll-common-card__title', '.poll-created .poll-common-chart-panel', '.poll-created .action-dock'],
      {
        padding: 32,
        width: 1200,
        height: 1800,
        clearSelection: true,
        spotlight: {selector: '.poll-common-outcome-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
      }
    );
  }
};
