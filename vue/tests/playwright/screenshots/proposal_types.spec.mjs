import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

const pollTypeDirectories = {
  poll: 'choose',
  score: 'score',
  dot_vote: 'allocate',
  ranked_choice: 'rank'
};

async function openPollTemplates(page) {
  await page.goto('/dev/setup_manual_oatmilk_formatting?key=0')
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.poll-common-choose-template__poll').click()
  await expectLabel(page.locator('.decision-tools-card__poll-types'), 'Rank')
}

async function addOption(page, name, meaning) {
  await page.locator('.poll-common-form__add-option-btn').click()
  await page.locator('.poll-option-form__name input').fill(name)
  if (meaning) { await page.locator('.poll-common-option-form textarea').fill(meaning); }
  await page.locator('.poll-option-form__done-btn').click()
}

async function openChooseForm(page) {
  await openPollTemplates(page);
  await page.locator('.decision-tools-card__poll-type--poll').click()
  await page.locator('.poll-common-form-fields__title input').fill('Which bottle trial topics need the most meeting time?')
  await page.locator('.poll-common-form-fields__details [contenteditable=true]').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('new-choose-poll', [
      'Choose up to two topics that need the most time at the Oatmilk Cooperative planning meeting.',
      'Consider which questions affect cafe staff, production work, and the delivery schedule.',
      'We will use the result to order the agenda and assign preparation before the meeting.'
    ]))
  await addOption(page, 'Cafe collection schedule', 'Confirm collection days and the contact at each cafe.');
  await addOption(page, 'Bottle deposit amount', 'Agree on a deposit that is clear for customers and cafe staff.');
  await addOption(page, 'Washing workflow', 'Check capacity, food-safety steps, and who records each batch.');
  await addOption(page, 'Return-rate reporting', 'Decide what each cafe reports during the six-week trial.');
  await page.locator('.poll-common-form__maximum-stance-choices input').fill('2')
}

async function startChoosePoll(page) {
  await openTypePoll(page, 'poll');
}

const pollTypes = {
  score: {
    title: 'Score possible locations for the bottle trial',
    details: 'Score each location from 0 (unsuitable) to 10 (ideal) for the six-week trial.',
    context: [
      'Consider customer access, staff capacity, storage space, and collection transport.',
      'Add a reason to identify advantages or constraints that the project team should check.'
    ],
    options: [
      ['Central Station cafe', 'High foot traffic with limited storage space.'],
      ['Riverside market', 'Weekend trading with space for a staffed collection point.'],
      ['University food court', 'High weekday demand and an existing washing facility.'],
      ['Harbour offices', 'Regular customers but collection transport is less frequent.']
    ],
    reason: 'I scored customer access highly and reduced scores where storage or transport may constrain collections.'
  },
  dot_vote: {
    title: "Set priorities for next year's strategy review",
    details: 'Allocate ten points across the areas that should receive the most time in our annual strategy review.',
    context: [
      'Consider what has changed over the past year and where a deeper review would most improve our plans.',
      'Add a reason to explain which opportunities, risks, or unresolved questions shaped your allocation.'
    ],
    options: [
      ['Member participation', 'Review how members contribute to decisions and cooperative activities.'],
      ['Financial sustainability', 'Review revenue, costs, reserves, and financial risks.'],
      ['Products and services', 'Review what we offer and how well it meets member needs.'],
      ['Environmental impact', 'Review emissions, waste, sourcing, and practical improvements.'],
      ['Staff development', 'Review staffing, skills, workload, and development needs.']
    ],
    reason: 'I gave more time to member participation and financial sustainability because both need decisions before we set next year’s priorities.'
  },
  ranked_choice: {
    title: 'Rank the bottle designs for the trial',
    details: 'Rank the four bottle designs in the order the cooperative should consider them for the trial.',
    context: [
      'Consider handling, durability, customer needs, storage, and compatibility with washing equipment.',
      'Add a reason to explain the criteria behind your order of preference.'
    ],
    options: [
      ['500 ml amber bottle', 'Protects contents from light and fits existing cafe storage.'],
      ['500 ml clear bottle', 'Shows the product and fits existing cafe storage.'],
      ['750 ml amber bottle', 'Larger serving with light protection.'],
      ['1 litre clear bottle', 'Family size with higher storage and handling requirements.']
    ],
    reason: 'I ranked the designs by handling, storage, and compatibility with the existing washing equipment.'
  }
};

async function openTypeForm(page, pollType) {
  const config = pollTypes[pollType];
  await page.goto(`/dev/setup_manual_oatmilk_new_poll?poll_type=${pollType}`)
  await expect(page.locator('.poll-common-form').first()).toBeVisible()
  await page.locator('.poll-common-form-fields__title input').fill(config.title)
  await page.locator('.poll-common-form-fields__details [contenteditable=true]').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context(`new-${pollType}`, [
    config.details,
    ...config.context
  ]))
  config.options.forEach(([name, meaning]) => addOption(page, name, meaning));

  if (pollType === 'dot_vote') {
    await page.locator('.poll-common-form input[type="number"]').fill('10')
  }

  if (pollType === 'score') {
    await page.locator('.poll-score-form__max input').fill('10')
  }

  if (pollType === 'ranked_choice') {
    await page.locator('.poll-common-form .lmo-number-input input').fill('4')
  }
}

async function openTypePoll(page, pollType, mode) {
  const suffix = mode ? `&mode=${mode}` : '';
  await page.goto(`/dev/setup_manual_oatmilk_poll_type?poll_type=${pollType}${suffix}`)
  await expect(page.locator('.poll-created').first()).toBeVisible()
  await expectLabel(page.locator('.poll-common-card__title'), pollTypes[pollType]?.title || 'Which bottle trial topics need the most meeting time?')
}

async function captureTypeForm(screenshot, pollType) {
  await screenshot.captureElement(
    `polls/${pollTypeDirectories[pollType]}/form`,
    '.poll-common-form',
    {width: 1100, height: 2800}
  );
}

async function captureVoteForm(screenshot, pollType, root) {
  await screenshot.captureRegion(
    `polls/${pollTypeDirectories[pollType]}/voting`,
    ['.poll-common-action-panel h3', root, `${root} .poll-common-form-actions`],
    {width: 1100, height: 2400, padding: 16}
  );
}

async function captureResults(screenshot, pollType) {
  await screenshot.captureRegion(
    `polls/${pollTypeDirectories[pollType]}/results`,
    ['.poll-common-card__title', '.poll-common-chart-panel'],
    {width: 1100, height: 2200, padding: 16}
  );
}

async function captureOutcome(page, screenshot, pollType) {
  await openTypePoll(page, pollType, 'outcome');
  await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible()
  await screenshot.captureRegion(
    `polls/${pollTypeDirectories[pollType]}/outcome`,
    ['.poll-created .poll-common-card__title', '.poll-created .poll-common-chart-panel', '.poll-created .action-dock'],
    {
      padding: 32,
      width: 1200,
      height: 2400,
      clearSelection: true,
      spotlight: {selector: '.poll-common-outcome-panel', padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0}
    }
  );
}

test('new_simple_poll', async ({ page, manual: screenshot }) => {
  await openChooseForm(page);
  await screenshot.captureElement(
    'polls/choose/form',
    '.poll-common-form',
    {width: 1100, height: 1800}
  );
});

test('poll_edit_option', async ({ page, manual: screenshot }) => {
  await openChooseForm(page);
  await page.evaluate(`
    const item = Array.from(document.querySelectorAll('.poll-common-form .v-list-item'))
      .find(el => el.textContent.includes('Cafe collection schedule'));
    item.classList.add('manual-cafe-option');
  `)
  await page.locator('.manual-cafe-option .poll-common-form__edit-option').click()
  await screenshot.captureElement(
    'polls/choose/edit_option',
    '.poll-common-option-form',
    {width: 1000, height: 900}
  );
});

test('new_simple_poll_random', async ({ page, manual: screenshot }) => {
  await openChooseForm(page);
  await page.locator('.poll-common-form__more-settings').click()
  await page.locator('.poll-settings-shuffle-options .v-selection-control__wrapper').click()
  await page.evaluate(`
    const checkbox = document.querySelector('.poll-settings-shuffle-options');
    const heading = checkbox.previousElementSibling.previousElementSibling;
    const wrapper = document.createElement('div');
    wrapper.className = 'manual-shuffle-capture';
    Object.assign(wrapper.style, {
      position: 'fixed', top: '0', left: '0', width: '100%', zIndex: '9999',
      padding: '24px', background: 'white'
    });
    [heading, heading.nextElementSibling, checkbox].forEach(el => wrapper.append(el.cloneNode(true)));
    document.body.append(wrapper);
  `)
  await screenshot.captureElement(
    'polls/choose/random_order',
    '.manual-shuffle-capture',
    {width: 1100, height: 1000}
  );
});

test('new_simple_poll_voting', async ({ page, manual: screenshot }) => {
  await startChoosePoll(page);
  await page.evaluate(`
    Array.from(document.querySelectorAll('.poll-common-vote-form__button'))
      .find(el => el.textContent.includes('Cafe collection schedule'))
      .querySelector('label').click();
  `)
  await page.evaluate(`
    Array.from(document.querySelectorAll('.poll-common-vote-form__button'))
      .find(el => el.textContent.includes('Washing workflow'))
      .querySelector('label').click();
  `)
  await page.locator('.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]').fill('These topics affect every cafe collection, so we should confirm them together before the trial starts.')
  await page.evaluate("document.querySelector('.poll-common-action-panel h3').scrollIntoView({block: 'start'})")
  await screenshot.captureRegion(
    'polls/choose/voting',
    [
      '.poll-common-action-panel h3',
      '.poll-common-vote-form > .v-alert',
      '.poll-common-vote-form__button:has(input[aria-label="Cafe collection schedule"])',
      '.poll-common-vote-form__button:has(input[aria-label="Bottle deposit amount"])',
      '.poll-common-vote-form__button:has(input[aria-label="Washing workflow"])',
      '.poll-common-vote-form__button:has(input[aria-label="Return-rate reporting"])',
      '.poll-common-vote-form__reason',
      '.poll-common-form-actions'
    ],
    {width: 1100, height: 2200, padding: 16}
  );
});

test('poll_results', async ({ page, manual: screenshot }) => {
  await openTypePoll(page, 'poll', 'results');
  await captureResults(screenshot, 'poll');
});

test('poll_outcome', async ({ page, manual: screenshot }) => {
  await captureOutcome(page, screenshot, 'poll');
});

test('score_outcome', async ({ page, manual: screenshot }) => {
  await captureOutcome(page, screenshot, 'score');
});

test('dot_vote_outcome', async ({ page, manual: screenshot }) => {
  await captureOutcome(page, screenshot, 'dot_vote');
});

test('ranked_choice_outcome', async ({ page, manual: screenshot }) => {
  await captureOutcome(page, screenshot, 'ranked_choice');
});

test('score_options', async ({ page, manual: screenshot }) => {
  await openTypeForm(page, 'score');
  await captureTypeForm(screenshot, 'score');
});

test('score_voting', async ({ page, manual: screenshot }) => {
  await openTypePoll(page, 'score');
  await page.evaluate("document.querySelectorAll('.vote-form-number-input').forEach((input, index) => { input.value = [8, 6, 7, 5][index]; input.dispatchEvent(new Event('input', {bubbles: true})); })")
  await page.locator('.poll-score-vote-form .poll-common-vote-form__reason [contenteditable=true]').fill(pollTypes.score.reason)
  await captureVoteForm(screenshot, 'score', '.poll-score-vote-form');
});

test('score_results', async ({ page, manual: screenshot }) => {
  await openTypePoll(page, 'score', 'results');
  await captureResults(screenshot, 'score');
});

test('dot_vote_options', async ({ page, manual: screenshot }) => {
  await openTypeForm(page, 'dot_vote');
  await captureTypeForm(screenshot, 'dot_vote');
});

test('dot_vote_voting', async ({ page, manual: screenshot }) => {
  await openTypePoll(page, 'dot_vote');
  await page.evaluate("document.querySelectorAll('.poll-dot-vote-vote-form .vote-form-number-input').forEach((input, index) => { input.value = [3, 3, 0, 2, 2][index]; input.dispatchEvent(new Event('input', {bubbles: true})); })")
  await page.locator('.poll-dot-vote-vote-form .poll-common-vote-form__reason [contenteditable=true]').fill(pollTypes.dot_vote.reason)
  await captureVoteForm(screenshot, 'dot_vote', '.poll-dot-vote-vote-form');
});

test('dot_vote_results', async ({ page, manual: screenshot }) => {
  await openTypePoll(page, 'dot_vote', 'results');
  await captureResults(screenshot, 'dot_vote');
});

test('ranked_choice_options', async ({ page, manual: screenshot }) => {
  await openTypeForm(page, 'ranked_choice');
  await captureTypeForm(screenshot, 'ranked_choice');
});

test('ranked_choice_voting', async ({ page, manual: screenshot }) => {
  await openTypePoll(page, 'ranked_choice');
  await page.locator('.poll-ranked-choice-vote-form .poll-common-vote-form__reason [contenteditable=true]').fill(pollTypes.ranked_choice.reason)
  await captureVoteForm(screenshot, 'ranked_choice', '.poll-ranked-choice-vote-form');
});

test('ranked_choice_results', async ({ page, manual: screenshot }) => {
  await openTypePoll(page, 'ranked_choice', 'results');
  await captureResults(screenshot, 'ranked_choice');
});
