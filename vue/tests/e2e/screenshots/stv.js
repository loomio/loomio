const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

function addOption(page, name) {
  page.clickAndWait('.poll-common-form__add-option-btn', '.poll-common-option-form');
  page.fillIn('.poll-option-form__name input', name);
  page.clickAndWait('.poll-option-form__done-btn', '.poll-common-form__add-option-btn');
}

function openStvForm(page) {
  page.loadPath('setup_manual_oatmilk_new_poll?poll_type=stv');
  page.waitFor('.poll-common-form');
  page.fillIn('.poll-common-form-fields__title input', 'Elect the reusable packaging committee');
  page.fillRichText('.poll-common-form-fields__details [contenteditable=true]', richText.context('new-stv-election', [
    'Elect three people to oversee bottle deposits, cafe collections, washing, and the review of the six-week trial.',
    'Rank as many candidates as you can support so your vote can transfer if a candidate is elected or eliminated.',
    'The three elected candidates will report to the cooperative after the trial.'
  ]));
  ['Samira Patel', 'Alex Morgan', 'Taylor Reed', 'Morgan Price', 'Riley Thompson'].forEach(name => addOption(page, name));
  page.clear('.poll-common-form .lmo-number-input input');
  page.fillIn('.poll-common-form .lmo-number-input input', '3');
}

function openStvPoll(page, results = false) {
  page.loadPath(`setup_manual_oatmilk_stv${results ? '?results=1' : ''}`);
  page.expectText('.poll-created', 'Elect the reusable packaging committee');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'form': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openStvForm(page);
    screenshot.captureElement(
      'polls/stv/form',
      '.poll-common-form',
      {width: 1100, height: 2800}
    );
  },

  'vote_in_progress': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openStvPoll(page);
    page.waitFor('.poll-stv-vote-form');
    page.execute(`
      const form = document.querySelector('.poll-stv-vote-form');
      const divider = form.querySelector('.poll-stv-vote-form__divider');
      const list = divider.parentElement;
      const names = ['Samira Patel', 'Alex Morgan', 'Morgan Price'];
      names.forEach((name, index) => {
        const option = Array.from(form.querySelectorAll('.poll-stv-vote-form__option'))
          .find(el => el.textContent.includes(name));
        option.classList.remove('poll-stv-vote-form__option--unranked');
        const append = option.querySelector('.v-list-item__append');
        append.innerHTML = '<span class="text-medium-emphasis" style="font-size: 1.2rem"># ' + (index + 1) + '</span>';
        list.insertBefore(option, divider);
      });
      form.scrollIntoView({block: 'center'});
    `);
    page.pause(200);
    screenshot.captureElement(
      'polls/stv/stv-vote-in-progress',
      '.poll-stv-vote-form',
      {width: 1100, height: 1400}
    );
  },

  'results_summary': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openStvPoll(page, true);
    page.waitFor('.poll-stv-chart-panel');
    page.expectText('.poll-stv-chart-panel', 'Scottish STV');
    screenshot.captureElement(
      'polls/stv/stv-results-summary',
      '.poll-stv-chart-panel',
      {width: 1200, height: 1000}
    );
  },

  'round_details': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openStvPoll(page, true);
    page.waitFor('.poll-stv-chart-panel');
    page.clickAndWait('.poll-stv-chart-panel .v-expansion-panel-title', '.poll-stv-chart-panel .v-expansion-panel-text');
    screenshot.captureElement(
      'polls/stv/stv-results',
      '.poll-stv-chart-panel',
      {width: 1400, height: 1400}
    );
  }
};
