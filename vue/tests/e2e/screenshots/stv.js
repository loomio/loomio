const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openStvPoll(page, results = false) {
  page.loadPath(`setup_manual_oatmilk_stv${results ? '?results=1' : ''}`);
  page.expectText('.poll-created', 'Elect the reusable packaging committee');
}

module.exports = {
  '@tags': ['manual-screenshot'],

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
