const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

function openProposalForm(page) {
  page.loadPath('setup_manual_oatmilk_formatting?key=0');
  page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
  page.expectText('.decision-tools-card__poll-types', 'Consent');
  page.click('.decision-tools-card__template--consent');
  page.waitFor('.poll-common-form-fields__title input');
  page.fillIn('.poll-common-form-fields__title input', 'Approve the returnable bottle trial budget');
  page.fillRichText(
    '.poll-common-form-fields__details [contenteditable=true]',
    richText.context('quorum-proposal', [
      'Approve the bottle deposits, washing costs, and collection budget for the six-week trial.',
      'The budget covers three cafe partners, weekly collections, replacement bottles, and batch records.',
      'Review the figures before voting and explain any cost that should be adjusted.'
    ])
  );
}

function openQuorumPoll(page, votes) {
  page.loadPath(`setup_manual_oatmilk_quorum?votes=${votes}`);
  page.waitFor('.poll-created .poll-common-chart-panel');
  page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
  page.expectText('.poll-created', `${votes} of 5 votes cast (${votes * 20}% participation)`);
  page.pause(400);
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'proposal_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.resizeWindow(1200, 2000);
    openProposalForm(page);
    screenshot.captureRegion(
      'polls/quorum/proposal-options',
      ['.poll-common-form > .v-card-title', '.poll-common-form__voters-heading + .v-input'],
      {padding: 0, width: 1200, height: 2000, clearSelection: true, scrollSelector: '.poll-common-form > .v-card-title', scrollBlock: 'start'}
    );
  },

  'quorum_section': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openProposalForm(page);
    page.clickAndWait('.poll-common-form__more-settings', '.poll-common-form__quorum-title');
    page.fillIn('.poll-common-form__quorum-title ~ .v-number-input input', '60');
    page.execute(`
      const title = document.querySelector('.poll-common-form__quorum-title');
      title.classList.add('manual-quorum-title');
      title.nextElementSibling.classList.add('manual-quorum-hint');
      title.nextElementSibling.nextElementSibling.classList.add('manual-quorum-input');
      title.nextElementSibling.nextElementSibling.nextElementSibling.classList.add('manual-quorum-tip');
      title.scrollIntoView({block: 'center'});
    `);
    page.pause(200);
    page.expectText('.poll-common-form__quorum', 'Quorum');
    screenshot.captureRegion(
      'polls/quorum/quorum-section',
      ['.poll-common-form__more-settings', '.manual-quorum-tip'],
      {padding: 16, width: 1200, height: 1400, scrollSelector: '.manual-quorum-title', spotlight: {selectors: ['.manual-quorum-title', '.manual-quorum-hint', '.manual-quorum-input', '.manual-quorum-tip'], padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
    );
  },

  'pie_chart_0': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openQuorumPoll(page, 0);
    screenshot.captureRegion(
      'polls/quorum/pie-chart-0',
      ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
      {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
    );
  },

  'pie_chart_40': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openQuorumPoll(page, 2);
    screenshot.captureRegion(
      'polls/quorum/pie-chart-40',
      ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
      {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
    );
  },

  'pie_chart_60': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openQuorumPoll(page, 3);
    screenshot.captureRegion(
      'polls/quorum/pie-chart-60',
      ['.poll-created .poll-common-card__title', '.poll-created .action-dock'],
      {padding: 16, width: 1600, height: 1800, scrollSelector: '.poll-created .poll-common-chart-panel', clearSelection: true, spotlight: {selector: '.poll-created .poll-common-chart-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}}
    );
  }
};
