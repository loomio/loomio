const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openProposalForm(page) {
  page.loadPath('setup_manual_oatmilk_formatting?key=0');
  page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-types');
  page.expectText('.decision-tools-card__poll-types', 'Consent');
  page.execute("Array.from(document.querySelectorAll('.decision-tools-card__poll-type')).find(el => el.textContent.includes('Consent')).click()");
  page.waitFor('.poll-common-form-fields__title input');
  page.fillIn('.poll-common-form-fields__title input', 'Approve the returnable bottle trial budget');
  page.fillIn(
    '.poll-common-form-fields__details [contenteditable=true]',
    'Approve the bottle deposits, washing costs, and collection budget for the six-week trial.'
  );
}

function openQuorumPoll(page, votes) {
  page.loadPath(`setup_manual_oatmilk_quorum?votes=${votes}`);
  page.waitFor('.poll-created .poll-common-chart-panel');
  page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
  page.pause(400);
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'proposal_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openProposalForm(page);
    page.execute(`
      const form = document.querySelector('.poll-common-form');
      const headings = Array.from(form.querySelectorAll('.text-body-large'));
      const optionsHeading = headings.find(el => el.textContent.trim() === 'Options');
      const durationHeading = headings.find(el => el.textContent.trim() === 'Duration');
      const votersHeading = headings.find(el => el.textContent.trim() === 'Who can vote?');
      const wrapper = document.createElement('div');
      wrapper.className = 'manual-quorum-options-capture';
      Object.assign(wrapper.style, {
        position: 'fixed', top: '0', left: '0', width: '100%', zIndex: '9999',
        padding: '24px', background: 'white'
      });
      [
        form.querySelector('.poll-common-form-fields__title'),
        form.querySelector('.poll-common-form-fields__details'),
        optionsHeading,
        optionsHeading.nextElementSibling,
        durationHeading,
        durationHeading.nextElementSibling,
        form.querySelector('.poll-common-closing-at-field'),
        votersHeading,
        votersHeading.nextElementSibling
      ].filter(Boolean).forEach(el => wrapper.append(el.cloneNode(true)));
      document.body.append(wrapper);
    `);
    screenshot.captureElement(
      'polls/quorum/proposal-options',
      '.manual-quorum-options-capture',
      {width: 1200, height: 1600}
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
    screenshot.captureRegion(
      'polls/quorum/quorum-section',
      ['.manual-quorum-title', '.manual-quorum-hint', '.manual-quorum-input', '.manual-quorum-tip'],
      {padding: 16, width: 1100, height: 1400}
    );
  },

  'pie_chart_0': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openQuorumPoll(page, 0);
    screenshot.captureElement(
      'polls/quorum/pie-chart-0',
      '.poll-created .poll-common-chart-panel',
      {width: 1200, height: 1000}
    );
  },

  'pie_chart_40': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openQuorumPoll(page, 2);
    screenshot.captureElement(
      'polls/quorum/pie-chart-40',
      '.poll-created .poll-common-chart-panel',
      {width: 1200, height: 1000}
    );
  },

  'pie_chart_60': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openQuorumPoll(page, 3);
    screenshot.captureElement(
      'polls/quorum/pie-chart-60',
      '.poll-created .poll-common-chart-panel',
      {width: 1200, height: 1000}
    );
  }
};
