import { test, expect } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function addOption(page, name) {
  await page.clickAndWait('.poll-common-form__add-option-btn', '.poll-common-option-form');
  await page.fillIn('.poll-option-form__name input', name);
  await page.clickAndWait('.poll-option-form__done-btn', '.poll-common-form__add-option-btn');
}

async function openStvForm(page) {
  await page.loadPath('setup_manual_oatmilk_new_poll?poll_type=stv');
  await page.waitFor('.poll-common-form');
  await page.fillIn('.poll-common-form-fields__title input', 'Elect the reusable packaging committee');
  await page.fillRichText('.poll-common-form-fields__details [contenteditable=true]', richText.context('new-stv-election', [
    'Elect three people to oversee bottle deposits, cafe collections, washing, and the review of the six-week trial.',
    'Rank as many candidates as you can support so your vote can transfer if a candidate is elected or eliminated.',
    'The three elected candidates will report to the cooperative after the trial.'
  ]));
  ['Samira Patel', 'Alex Morgan', 'Taylor Reed', 'Morgan Price', 'Riley Thompson'].forEach(name => addOption(page, name));
  await page.clear('.poll-common-form .lmo-number-input input');
  await page.fillIn('.poll-common-form .lmo-number-input input', '3');
}

async function openStvPoll(page, results = false) {
  await page.loadPath(`setup_manual_oatmilk_stv${results ? '?results=1' : ''}`);
  await page.expectText('.poll-created', 'Elect the reusable packaging committee');
}

test('form', async ({ lmo: page, manual: screenshot }) => {
  await openStvForm(page);
  await screenshot.captureElement(
    'polls/stv/form',
    '.poll-common-form',
    {width: 1100, height: 2800}
  );
});

test('vote_in_progress', async ({ lmo: page, manual: screenshot }) => {
  await openStvPoll(page);
  await page.waitFor('.poll-stv-vote-form');
  await page.execute(`
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
  await page.pause(200);
  await screenshot.captureElement(
    'polls/stv/stv-vote-in-progress',
    '.poll-stv-vote-form',
    {width: 1100, height: 1400}
  );
});

test('results_summary', async ({ lmo: page, manual: screenshot }) => {
  await openStvPoll(page, true);
  await page.waitFor('.poll-stv-chart-panel');
  await page.expectText('.poll-stv-chart-panel', 'Scottish STV');
  await screenshot.captureElement(
    'polls/stv/stv-results-summary',
    '.poll-stv-chart-panel',
    {width: 1200, height: 1000}
  );
});

test('outcome', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_stv?results=1&outcome=1');
  await page.expectText('.poll-created', 'Elect the reusable packaging committee');
  await page.waitFor('.poll-common-outcome-panel');
  await screenshot.captureRegion(
    'polls/stv/outcome',
    ['.poll-created .poll-common-card__title', '.poll-created .poll-stv-chart-panel', '.poll-created .action-dock'],
    {
      padding: 32,
      width: 1200,
      height: 2400,
      clearSelection: true,
      spotlight: {selector: '.poll-common-outcome-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
    }
  );
});

test('round_details', async ({ lmo: page, manual: screenshot }) => {
  await openStvPoll(page, true);
  await page.waitFor('.poll-stv-chart-panel');
  await page.clickAndWait('.poll-stv-chart-panel .v-expansion-panel-title', '.poll-stv-chart-panel .v-expansion-panel-text');
  await screenshot.captureElement(
    'polls/stv/stv-results',
    '.poll-stv-chart-panel',
    {width: 1400, height: 1400}
  );
});
