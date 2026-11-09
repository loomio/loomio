import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import richText, { fillRichText } from '../helpers/oatmilkRichText.mjs';

const candidates = ['Samira Patel', 'Alex Morgan', 'Taylor Reed', 'Morgan Price', 'Riley Thompson'];
const outcomeSpotlight = {selector: '.poll-common-outcome-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0};

async function addOption(page, name) {
  await page.locator('.poll-common-form__add-option-btn').click()
  await page.locator('.poll-option-form__name input').fill(name)
  await page.locator('.poll-option-form__done-btn').click()
}

async function openStvForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_new_poll?poll_type=stv')
  await page.locator('.poll-common-form-fields__title input').fill('Elect the reusable packaging committee')
  await fillRichText(editor(page.locator('.poll-common-form-fields__details')), richText.context('new-stv-election', [
    'Elect three people to oversee bottle deposits, cafe collections, washing, and the review of the six-week trial.',
    'Rank as many candidates as you can support so your vote can transfer if a candidate is elected or eliminated.',
    'The three elected candidates will report to the cooperative after the trial.'
  ]))
  for (const name of candidates) { await addOption(page, name); }
  await page.locator('.poll-common-form .lmo-number-input input').fill('3')
}

async function openStvPoll(page, results = false) {
  await page.goto(`/dev/setup_manual_oatmilk_stv${results ? '?results=1' : ''}`)
  await expectLabel(page.locator('.poll-created'), 'Elect the reusable packaging committee')
}

test('form', async ({ page, manual: screenshot }) => {
  await openStvForm(page);
  await screenshot.captureElement(
    'polls/stv/form',
    '.poll-common-form',
    {width: 1100, height: 2800}
  );
});

test('vote_in_progress', async ({ page, manual: screenshot }) => {
  await openStvPoll(page);
  // Voters rank by dragging, so the picture moves three candidates above the
  // divider and numbers them as the form would.
  await page.locator('.poll-stv-vote-form').evaluate((form, names) => {
    const divider = form.querySelector('.poll-stv-vote-form__divider');
    const list = divider.parentElement;
    names.forEach((name, index) => {
      const option = Array.from(form.querySelectorAll('.poll-stv-vote-form__option'))
        .find(el => el.textContent.includes(name));
      option.classList.remove('poll-stv-vote-form__option--unranked');
      const append = option.querySelector('.v-list-item__append');
      append.innerHTML = '<span class="text-medium-emphasis" style="font-size: 1.2rem"># ' + (index + 1) + '</span>';
      list.insertBefore(option, divider);
    });
    form.scrollIntoView({block: 'center'});
  }, ['Samira Patel', 'Alex Morgan', 'Morgan Price'])
  await screenshot.captureElement(
    'polls/stv/stv-vote-in-progress',
    '.poll-stv-vote-form',
    {width: 1100, height: 1400}
  );
});

test('results_summary', async ({ page, manual: screenshot }) => {
  await openStvPoll(page, true);
  await expectLabel(page.locator('.poll-stv-chart-panel'), 'Scottish STV')
  await screenshot.captureElement(
    'polls/stv/stv-results-summary',
    '.poll-stv-chart-panel',
    {width: 1200, height: 1000}
  );
});

test('outcome', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_stv?results=1&outcome=1')
  await expectLabel(page.locator('.poll-created'), 'Elect the reusable packaging committee')
  await expect(page.locator('.poll-common-outcome-panel')).toBeVisible()
  await screenshot.captureRegion(
    'polls/stv/outcome',
    ['.poll-created .poll-common-card__title', '.poll-created .poll-stv-chart-panel', '.poll-created .action-dock'],
    {padding: 32, width: 1200, height: 2400, clearSelection: true, spotlight: outcomeSpotlight}
  );
});

test('round_details', async ({ page, manual: screenshot }) => {
  await openStvPoll(page, true);
  const chart = page.locator('.poll-stv-chart-panel')
  await chart.locator('.v-expansion-panel-title').click()
  await expect(chart.locator('.v-expansion-panel-text')).toBeVisible()
  await screenshot.captureElement(
    'polls/stv/stv-results',
    '.poll-stv-chart-panel',
    {width: 1400, height: 1400}
  );
});
