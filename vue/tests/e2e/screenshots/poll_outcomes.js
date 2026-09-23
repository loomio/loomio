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
    screenshot.captureElement(
      'polls/outcomes/outcome_prompt',
      '.poll-common-set-outcome-panel',
      {width: 1100, height: 700}
    );
  },

  'outcome_statement': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openOutcome(page);
    page.clickAndWait('.poll-common-set-outcome-panel__submit', '.poll-common-outcome-modal');
    page.fillIn(
      '.poll-common-outcome-form__statement [contenteditable=true]',
      'The cooperative approved the six-week returnable bottle trial. Jamie will confirm the cafe collection schedule, and we will review return rates and washing time when the trial ends.'
    );
    screenshot.captureElement(
      'polls/outcomes/outcome_statement',
      '.poll-common-outcome-modal',
      {width: 1280, height: 900}
    );
  },

  'outcome_published': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openOutcome(page, true);
    page.waitFor('.poll-common-outcome-panel');
    page.expectText('.poll-common-outcome-panel', 'Jamie will confirm the cafe collection schedule');
    screenshot.captureElement(
      'polls/outcomes/outcome_published',
      '.poll-common-outcome-panel',
      {width: 1100, height: 800}
    );
  }
};
