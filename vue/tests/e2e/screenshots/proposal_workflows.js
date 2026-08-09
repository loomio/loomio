const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

const workflows = [
  ['advice', 'proposal_advice'],
  ['consent', 'proposal_consent'],
  ['consensus', 'proposal_consensus'],
  ['check', 'proposal_sense_check'],
  ['gradients_of_agreement', 'proposal_gradients']
];

function loadPoll(page, template, mode) {
  page.loadPath(`setup_manual_oatmilk_proposal_template_poll?template=${template}${mode ? `&mode=${mode}` : ''}`);
  page.waitFor('.poll-common-card__title');
}

function captureVoting(screenshot, name) {
  screenshot.captureRegion(
    `polls/proposals/${name}_voting`,
    ['.poll-common-card__title', '.poll-common-action-panel'],
    {width: 1100, height: 2200, padding: 16}
  );
}

function captureResults(screenshot, name) {
  screenshot.captureRegion(
    `polls/proposals/${name}_results`,
    ['.poll-common-card__title', '.poll-common-chart-panel'],
    {width: 1100, height: 2200, padding: 16}
  );
}

const tests = {
  '@tags': ['manual-screenshot'],

  'proposal_templates_list': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_formatting?key=0');
    page.waitFor('.activity-panel__add-poll');
    page.clickAndWait('.activity-panel__add-poll', '.poll-common-templates-list');
    screenshot.captureElement('polls/proposals/proposal_templates_list', '.poll-common-templates-list', {width: 1100, height: 1400});
  },

  'proposal_classic_voting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadPoll(page, 'majority');
    captureVoting(screenshot, 'proposal_classic');
  },

  'proposal_question': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadPoll(page, 'question');
    screenshot.captureRegion(
      'polls/proposals/proposal_question',
      ['.poll-common-card__title', '.poll-common-action-panel'],
      {width: 1100, height: 2200, padding: 16}
    );
  }
};

workflows.forEach(([template, name]) => {
  tests[`${name}_voting`] = (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadPoll(page, template);
    captureVoting(screenshot, name);
  };

  tests[`${name}_results`] = (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    loadPoll(page, template, 'results');
    page.waitFor('.poll-common-chart-panel');
    captureResults(screenshot, name);
  };
});

module.exports = tests;
