const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function spotlight(selectors) {
  return {
    selectors,
    padding: 16,
    radius: 20,
    opacity: 0.4,
    outlineWidth: 0
  };
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'process_run': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_formatting?key=0');
    page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
    page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
    page.expectText('.decision-tools-card__poll-types', 'Sense check');
    screenshot.captureElement(
      'polls/intro_to_decisions/process_run',
      '.actions-panel',
      {width: 1280, height: 1000}
    );
  },

  'standalone_poll': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.clickAndWait('.group-page-polls-tab', '.polls-panel__new-poll-button');
    page.expectText('.polls-panel__new-poll-button', 'New poll');
    screenshot.capture('polls/intro_to_decisions/standalone_poll', {
      width: 1280,
      height: 900,
      spotlight: spotlight(['.group-page-polls-tab', '.polls-panel__new-poll-button'])
    });
  }
};
