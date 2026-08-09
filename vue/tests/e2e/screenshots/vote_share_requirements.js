const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function spotlight(selector) {
  return {selector, padding: 16, radius: 16, opacity: 0.4, outlineWidth: 0};
}

function openConsentForm(page) {
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
  page.execute(`
    const heading = Array.from(document.querySelectorAll('.poll-common-form .text-body-large'))
      .find(el => el.textContent.trim() === 'Options');
    heading.classList.add('manual-options-heading');
    heading.nextElementSibling.classList.add('manual-options-list');
    const option = Array.from(heading.nextElementSibling.querySelectorAll('.v-list-item'))
      .find(el => el.textContent.includes('Consent'));
    option.classList.add('manual-consent-option');
  `);
  page.waitFor('.manual-consent-option');
}

function openConsentOption(page) {
  openConsentForm(page);
  page.clickAndWait('.manual-consent-option button[title="Edit"]', '.poll-common-option-form');
}

function enableVoteShare(page, percent) {
  page.click('.poll-common-option-form .v-checkbox .v-selection-control__wrapper');
  page.fillIn('.poll-common-option-form .v-number-input input', String(percent));
  page.execute("document.querySelectorAll('.poll-common-option-form .v-select').item(1).classList.add('manual-vote-against-select')");
  page.click('.manual-vote-against-select .v-field');
  page.waitFor('.v-overlay--active .v-list');
  page.execute("Array.from(document.querySelectorAll('.v-overlay--active .v-list-item')).find(el => el.textContent.includes('Eligible voters')).click()");
  page.pause(200);
  page.execute("document.querySelectorAll('.poll-common-option-form .v-select').item(1).classList.add('manual-vote-against-select')");
  page.expectText('.manual-vote-against-select', 'Eligible voters');
}

function openVoteSharePoll(page, votes) {
  page.loadPath(`setup_manual_oatmilk_quorum?vote_share=1&votes=${votes}`);
  page.waitFor('.poll-created .poll-common-chart-panel');
  page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
  page.pause(400);
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'edit_highlight_on_option': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openConsentForm(page);
    screenshot.captureRegion(
      'polls/vote_share_requirements/edit-highlight-on-option',
      ['.manual-options-heading', '.manual-consent-option'],
      {
        padding: 12,
        width: 1200,
        height: 1200,
        spotlight: spotlight('.manual-consent-option button[title="Edit"]')
      }
    );
  },

  'eligible_vs_cast': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openConsentOption(page);
    enableVoteShare(page, 60);
    page.click('.manual-vote-against-select .v-field');
    page.waitFor('.v-overlay--active .v-list');
    page.execute(`
      const heading = Array.from(document.querySelectorAll('.poll-common-option-form .text-body-large'))
        .find(el => el.textContent.trim() === 'Vote share requirement');
      heading.classList.add('manual-vote-share-heading');
      heading.nextElementSibling.classList.add('manual-vote-share-checkbox');
      heading.nextElementSibling.nextElementSibling.classList.add('manual-vote-share-fields');
      document.querySelector('.poll-option-form__done-btn').style.visibility = 'hidden';
    `);
    screenshot.captureRegion(
      'polls/vote_share_requirements/eligible-vs-cast',
      ['.manual-vote-share-heading', '.manual-vote-share-checkbox', '.manual-vote-share-fields', '.v-overlay--active .v-list'],
      {padding: 4, width: 1100, height: 1200}
    );
  },

  'consent_vote_option': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openConsentOption(page);
    enableVoteShare(page, 75);
    screenshot.captureElement(
      'polls/vote_share_requirements/consent-vote-option',
      '.poll-common-option-form',
      {width: 1100, height: 1400}
    );
  },

  'first_vote_breakdown': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openVoteSharePoll(page, 2);
    screenshot.captureElement(
      'polls/vote_share_requirements/first-vote-breakdown',
      '.poll-created .poll-common-chart-panel',
      {width: 1200, height: 1000}
    );
  },

  'final_vote_breakdown': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openVoteSharePoll(page, 5);
    screenshot.captureElement(
      'polls/vote_share_requirements/final-vote-breakdown',
      '.poll-created .poll-common-chart-panel',
      {width: 1200, height: 1000}
    );
  }
};
