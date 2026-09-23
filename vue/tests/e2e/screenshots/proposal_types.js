const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

const pollTypeDirectories = {
  poll: 'choose',
  score: 'score',
  dot_vote: 'allocate',
  ranked_choice: 'rank'
};

function openPollTemplates(page) {
  page.loadPath('setup_manual_oatmilk_formatting?key=0');
  page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll');
  page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--poll');
  page.expectText('.decision-tools-card__poll-types', 'Rank');
}

function addOption(page, name, meaning) {
  page.clickAndWait('.poll-common-form__add-option-btn', '.poll-common-option-form');
  page.fillIn('.poll-option-form__name input', name);
  if (meaning) page.fillIn('.poll-common-option-form textarea', meaning);
  page.clickAndWait('.poll-option-form__done-btn', '.poll-common-form__add-option-btn');
}

function openChooseForm(page) {
  openPollTemplates(page);
  page.clickAndWait('.decision-tools-card__poll-type--poll', '.poll-common-form-fields__title input');
  page.fillIn('.poll-common-form-fields__title input', 'Which bottle trial topics need the most meeting time?');
  page.fillRichText(
    '.poll-common-form-fields__details [contenteditable=true]',
    richText.context('new-choose-poll', [
      'Choose up to two topics that need the most time at the Oatmilk Cooperative planning meeting.',
      'Consider which questions affect cafe staff, production work, and the delivery schedule.',
      'We will use the result to order the agenda and assign preparation before the meeting.'
    ])
  );
  addOption(page, 'Cafe collection schedule', 'Confirm collection days and the contact at each cafe.');
  addOption(page, 'Bottle deposit amount', 'Agree on a deposit that is clear for customers and cafe staff.');
  addOption(page, 'Washing workflow', 'Check capacity, food-safety steps, and who records each batch.');
  addOption(page, 'Return-rate reporting', 'Decide what each cafe reports during the six-week trial.');
  page.clear('.poll-common-form__maximum-stance-choices input');
  page.fillIn('.poll-common-form__maximum-stance-choices input', '2');
}

function startChoosePoll(page) {
  openTypePoll(page, 'poll');
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

function openTypeForm(page, pollType) {
  const config = pollTypes[pollType];
  page.loadPath(`setup_manual_oatmilk_new_poll?poll_type=${pollType}`);
  page.waitFor('.poll-common-form');
  page.fillIn('.poll-common-form-fields__title input', config.title);
  page.fillRichText('.poll-common-form-fields__details [contenteditable=true]', richText.context(`new-${pollType}`, [
    config.details,
    ...config.context
  ]));
  config.options.forEach(([name, meaning]) => addOption(page, name, meaning));

  if (pollType === 'dot_vote') {
    page.clear('.poll-common-form input[type="number"]');
    page.fillIn('.poll-common-form input[type="number"]', '10');
  }

  if (pollType === 'score') {
    page.clear('.poll-score-form__max input');
    page.fillIn('.poll-score-form__max input', '10');
  }

  if (pollType === 'ranked_choice') {
    page.clear('.poll-common-form .lmo-number-input input');
    page.fillIn('.poll-common-form .lmo-number-input input', '4');
  }
}

function openTypePoll(page, pollType, mode) {
  const suffix = mode ? `&mode=${mode}` : '';
  page.loadPath(`setup_manual_oatmilk_poll_type?poll_type=${pollType}${suffix}`);
  page.waitFor('.poll-created');
  page.expectText('.poll-common-card__title', pollTypes[pollType]?.title || 'Which bottle trial topics need the most meeting time?');
}

function captureTypeForm(screenshot, pollType) {
  screenshot.captureElement(
    `polls/${pollTypeDirectories[pollType]}/form`,
    '.poll-common-form',
    {width: 1100, height: 2800}
  );
}

function captureVoteForm(screenshot, pollType, root) {
  screenshot.captureRegion(
    `polls/${pollTypeDirectories[pollType]}/voting`,
    ['.poll-common-action-panel h3', root, `${root} .poll-common-form-actions`],
    {width: 1100, height: 2400, padding: 16}
  );
}

function captureResults(screenshot, pollType) {
  screenshot.captureRegion(
    `polls/${pollTypeDirectories[pollType]}/results`,
    ['.poll-common-card__title', '.poll-common-chart-panel'],
    {width: 1100, height: 2200, padding: 16}
  );
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'new_simple_poll': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openChooseForm(page);
    screenshot.captureElement(
      'polls/choose/form',
      '.poll-common-form',
      {width: 1100, height: 1800}
    );
  },

  'poll_edit_option': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openChooseForm(page);
    page.execute(`
      const item = Array.from(document.querySelectorAll('.poll-common-form .v-list-item'))
        .find(el => el.textContent.includes('Cafe collection schedule'));
      item.classList.add('manual-cafe-option');
    `);
    page.clickAndWait('.manual-cafe-option button[title="Edit"]', '.poll-common-option-form');
    screenshot.captureElement(
      'polls/choose/edit_option',
      '.poll-common-option-form',
      {width: 1000, height: 900}
    );
  },

  'new_simple_poll_random': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openChooseForm(page);
    page.clickAndWait('.poll-common-form__more-settings', '.poll-settings-shuffle-options');
    page.click('.poll-settings-shuffle-options .v-selection-control__wrapper');
    page.execute(`
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
    `);
    screenshot.captureElement(
      'polls/choose/random_order',
      '.manual-shuffle-capture',
      {width: 1100, height: 1000}
    );
  },

  'new_simple_poll_voting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    startChoosePoll(page);
    page.execute(`
      Array.from(document.querySelectorAll('.poll-common-vote-form__button'))
        .find(el => el.textContent.includes('Cafe collection schedule'))
        .querySelector('label').click();
    `);
    page.pause(100);
    page.execute(`
      Array.from(document.querySelectorAll('.poll-common-vote-form__button'))
        .find(el => el.textContent.includes('Washing workflow'))
        .querySelector('label').click();
    `);
    page.fillIn(
      '.poll-common-vote-form__reason .lmo-textarea div[contenteditable=true]',
      'These topics affect every cafe collection, so we should confirm them together before the trial starts.'
    );
    page.execute("document.querySelector('.poll-common-action-panel h3').scrollIntoView({block: 'start'})");
    screenshot.captureRegion(
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
  },

  'poll_results': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'poll', 'results');
    captureResults(screenshot, 'poll');
  },

  'poll_outcome': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'poll', 'outcome');
    page.waitFor('.poll-common-outcome-panel');
    screenshot.captureElement(
      'polls/choose/outcome',
      '.poll-common-outcome-panel',
      {width: 1100, height: 1000}
    );
  },

  'score_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypeForm(page, 'score');
    captureTypeForm(screenshot, 'score');
  },

  'score_voting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'score');
    page.execute("document.querySelectorAll('.vote-form-number-input').forEach((input, index) => { input.value = [8, 6, 7, 5][index]; input.dispatchEvent(new Event('input', {bubbles: true})); })");
    page.fillIn('.poll-score-vote-form .poll-common-vote-form__reason [contenteditable=true]', pollTypes.score.reason);
    captureVoteForm(screenshot, 'score', '.poll-score-vote-form');
  },

  'score_results': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'score', 'results');
    captureResults(screenshot, 'score');
  },

  'dot_vote_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypeForm(page, 'dot_vote');
    captureTypeForm(screenshot, 'dot_vote');
  },

  'dot_vote_voting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'dot_vote');
    page.execute("document.querySelectorAll('.poll-dot-vote-vote-form .vote-form-number-input').forEach((input, index) => { input.value = [3, 3, 0, 2, 2][index]; input.dispatchEvent(new Event('input', {bubbles: true})); })");
    page.fillIn('.poll-dot-vote-vote-form .poll-common-vote-form__reason [contenteditable=true]', pollTypes.dot_vote.reason);
    captureVoteForm(screenshot, 'dot_vote', '.poll-dot-vote-vote-form');
  },

  'dot_vote_results': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'dot_vote', 'results');
    captureResults(screenshot, 'dot_vote');
  },

  'ranked_choice_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypeForm(page, 'ranked_choice');
    captureTypeForm(screenshot, 'ranked_choice');
  },

  'ranked_choice_voting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'ranked_choice');
    page.fillIn('.poll-ranked-choice-vote-form .poll-common-vote-form__reason [contenteditable=true]', pollTypes.ranked_choice.reason);
    captureVoteForm(screenshot, 'ranked_choice', '.poll-ranked-choice-vote-form');
  },

  'ranked_choice_results': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'ranked_choice', 'results');
    captureResults(screenshot, 'ranked_choice');
  }
};
