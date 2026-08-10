const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

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
    title: 'Assess our readiness for the returnable bottle trial',
    details: 'Score each part of the proposed trial from 0 (not ready) to 10 (ready).',
    options: [
      ['Cafe collection plan', 'Confirm collection days and contacts with each cafe.'],
      ['Washing capacity', 'Check equipment capacity and who records each batch.'],
      ['Food-safety process', 'Confirm the cleaning checks required before reuse.'],
      ['Return-rate reporting', 'Agree what each cafe reports during the trial.']
    ],
    reason: 'This score reflects the work completed and the checks still needed before launch.'
  },
  dot_vote: {
    title: 'Prioritise work for the returnable bottle trial',
    details: 'Allocate eight points across the work that needs attention before the six-week trial starts.',
    options: [
      ['Cafe collection schedule', 'Confirm collection days and contacts.'],
      ['Bottle deposit guidance', 'Make the deposit clear for customers and cafe staff.'],
      ['Washing workflow', 'Check equipment capacity and batch records.'],
      ['Food-safety checks', 'Confirm the cleaning checks required before reuse.'],
      ['Return-rate reporting', 'Agree what each cafe reports during the trial.']
    ],
    reason: 'I have allocated points to the work that carries the most operational risk.'
  },
  ranked_choice: {
    title: 'Rank the bottle trial priorities',
    details: 'Rank the four priorities in the order the cooperative should address them.',
    options: [
      ['Food-safety checks', 'Confirm the cleaning checks required before reuse.'],
      ['Washing workflow', 'Check equipment capacity and batch records.'],
      ['Cafe collection schedule', 'Confirm collection days and contacts.'],
      ['Return-rate reporting', 'Agree what each cafe reports during the trial.']
    ],
    reason: 'I ranked the work by safety impact and the dependencies between each step.'
  }
};

function openTypeForm(page, pollType) {
  const config = pollTypes[pollType];
  page.loadPath(`setup_manual_oatmilk_new_poll?poll_type=${pollType}`);
  page.waitFor('.poll-common-form');
  page.fillIn('.poll-common-form-fields__title input', config.title);
  page.fillRichText('.poll-common-form-fields__details [contenteditable=true]', richText.context(`new-${pollType}`, [
    config.details,
    'Base your response on the current cafe collection plan, washing capacity, and food-safety checks.',
    'Add a reason so the cooperative can understand what should happen before launch.'
  ]));
  config.options.forEach(([name, meaning]) => addOption(page, name, meaning));

  if (pollType === 'dot_vote') {
    page.clear('.poll-common-form input[type="number"]');
    page.fillIn('.poll-common-form input[type="number"]', '8');
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

function captureTypeLabel(screenshot, pollType, name) {
  screenshot.captureElement(
    `polls/proposal_types/${name}`,
    `.decision-tools-card__poll-type--${pollType}`,
    {width: 1100, height: 1000}
  );
}

function captureTypeForm(screenshot, name) {
  screenshot.captureElement(
    `polls/proposal_types/${name}`,
    '.poll-common-form',
    {width: 1100, height: 2800}
  );
}

function captureVoteForm(screenshot, root, name) {
  screenshot.captureRegion(
    `polls/proposal_types/${name}`,
    ['.poll-common-action-panel h3', root, `${root} .poll-common-form-actions`],
    {width: 1100, height: 2400, padding: 16}
  );
}

function captureResults(screenshot, name) {
  screenshot.captureRegion(
    `polls/proposal_types/${name}`,
    ['.poll-common-card__title', '.poll-common-chart-panel'],
    {width: 1100, height: 2200, padding: 16}
  );
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'poll_templates': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openPollTemplates(page);
    screenshot.captureElement(
      'polls/proposal_types/polls_templates',
      '.poll-common-templates-list',
      {width: 1100, height: 1200}
    );
  },

  'new_simple_poll': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openChooseForm(page);
    screenshot.captureElement(
      'polls/proposal_types/new_simple_poll',
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
      'polls/proposal_types/poll_edit_option',
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
      'polls/proposal_types/new_simple_poll_random',
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
      'polls/proposal_types/new_simple_poll_voting',
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
    captureResults(screenshot, 'poll_results');
  },

  'poll_outcome': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'poll', 'outcome');
    page.waitFor('.poll-common-outcome-panel');
    screenshot.captureElement(
      'polls/proposal_types/poll_outcome',
      '.poll-common-outcome-panel',
      {width: 1100, height: 1000}
    );
  },

  'score_label': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openPollTemplates(page);
    captureTypeLabel(screenshot, 'score', 'score_label');
  },

  'score_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypeForm(page, 'score');
    captureTypeForm(screenshot, 'score_options');
  },

  'score_voting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'score');
    page.execute("document.querySelectorAll('.vote-form-number-input').forEach((input, index) => { input.value = [8, 6, 7, 5][index]; input.dispatchEvent(new Event('input', {bubbles: true})); })");
    page.fillIn('.poll-score-vote-form .poll-common-vote-form__reason [contenteditable=true]', pollTypes.score.reason);
    captureVoteForm(screenshot, '.poll-score-vote-form', 'score_voting');
  },

  'score_results': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'score', 'results');
    captureResults(screenshot, 'score_results');
  },

  'dot_vote_label': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openPollTemplates(page);
    captureTypeLabel(screenshot, 'dot_vote', 'dot_vote_label');
  },

  'dot_vote_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypeForm(page, 'dot_vote');
    captureTypeForm(screenshot, 'dot_vote_options');
  },

  'dot_vote_voting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'dot_vote');
    page.execute("document.querySelectorAll('.poll-dot-vote-vote-form .vote-form-number-input').forEach((input, index) => { input.value = [3, 0, 3, 2, 0][index]; input.dispatchEvent(new Event('input', {bubbles: true})); })");
    page.fillIn('.poll-dot-vote-vote-form .poll-common-vote-form__reason [contenteditable=true]', pollTypes.dot_vote.reason);
    captureVoteForm(screenshot, '.poll-dot-vote-vote-form', 'dot_vote_voting');
  },

  'dot_vote_results': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'dot_vote', 'results');
    captureResults(screenshot, 'dot_vote_results');
  },

  'ranked_choice_label': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openPollTemplates(page);
    captureTypeLabel(screenshot, 'ranked_choice', 'ranked_choice_label');
  },

  'ranked_choice_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypeForm(page, 'ranked_choice');
    captureTypeForm(screenshot, 'ranked_choice_options');
  },

  'ranked_choice_voting': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'ranked_choice');
    page.fillIn('.poll-ranked-choice-vote-form .poll-common-vote-form__reason [contenteditable=true]', pollTypes.ranked_choice.reason);
    captureVoteForm(screenshot, '.poll-ranked-choice-vote-form', 'ranked_choice_voting');
  },

  'ranked_choice_results': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTypePoll(page, 'ranked_choice', 'results');
    captureResults(screenshot, 'ranked_choice_results');
  }
};
