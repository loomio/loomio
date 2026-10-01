const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function spotlight(selectors, padding = 16) {
  return {selectors, padding, radius: 16, opacity: 0.4, outlineWidth: 0};
}

// Opens the proposal used in the results screenshots, so the whole example
// follows one poll and its Agree option.
function openProposalForm(page) {
  page.loadPath('setup_manual_oatmilk_quorum?view=edit');
  page.waitFor('.poll-common-form-fields__title input');
  page.execute(`
    const heading = document.querySelector('.poll-common-form .poll-common-form__options-heading');
    heading.classList.add('manual-options-heading');
    const options = Array.from(document.querySelectorAll('.poll-common-form .v-list-item'));
    document.querySelector('.poll-common-form .poll-common-form__option--agree').classList.add('manual-agree-option');
    options[options.length - 1].classList.add('manual-last-option');
  `);
  page.waitFor('.manual-agree-option');
}

function openAgreeOption(page) {
  openProposalForm(page);
  page.clickAndWait('.manual-agree-option .poll-common-form__edit-option', '.poll-common-option-form');
  markVoteShareSection(page);
}

// Vue re-renders these fields when they change, which drops added classes, so mark them again after each change.
function markVoteShareSection(page) {
  page.execute(`
    const heading = document.querySelector('.poll-common-option-form .poll-option-form__vote-share-heading');
    heading.classList.add('manual-vote-share-heading');
    heading.nextElementSibling.classList.add('manual-vote-share-checkbox');
    heading.nextElementSibling.nextElementSibling.classList.add('manual-vote-share-fields');
    document.querySelectorAll('.poll-common-option-form .v-select').item(1).classList.add('manual-vote-against-select');
  `);
}

function enableVoteShare(page, percent) {
  page.click('.manual-vote-share-checkbox .v-selection-control__wrapper');
  page.pause(200);
  markVoteShareSection(page);
  page.fillIn('.manual-vote-share-fields .v-number-input input', String(percent));
  markVoteShareSection(page);
  page.click('.manual-vote-against-select .v-field');
  page.waitFor('.v-overlay--active .v-list');
  page.click('.v-overlay--active .poll-option-form__test-against--voter_percent');
  page.pause(300);
  markVoteShareSection(page);
  page.expectText('.manual-vote-against-select', 'Eligible voters');
}

function openVoteSharePoll(page, votes) {
  page.loadPath(`setup_manual_oatmilk_quorum?vote_share=1&votes=${votes}`);
  page.waitFor('.poll-created .poll-common-chart-panel');
  page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
  page.execute("document.querySelector('.poll-created .poll-common-chart-panel .v-alert').classList.add('manual-pass-requirements')");
  page.pause(400);
}

// The option window fits on screen, so show all of it with the relevant part spotlighted.
const optionWindow = ['.poll-common-option-form', '.poll-option-form__done-btn'];
const voteShareSection = ['.manual-vote-share-heading', '.manual-vote-share-checkbox', '.manual-vote-share-fields'];

module.exports = {
  '@tags': ['manual-screenshot'],

  'edit_highlight_on_option': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openProposalForm(page);
    screenshot.captureRegion(
      'polls/vote_share_requirements/edit-highlight-on-option',
      ['.poll-common-form > .v-card-title', '.manual-options-heading', '.manual-last-option', '.poll-common-form__add-option-btn'],
      {
        padding: 32,
        width: 1200,
        height: 1600,
        spotlight: spotlight(['.manual-agree-option .poll-common-form__edit-option'], 10)
      }
    );
  },

  'eligible_vs_cast': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAgreeOption(page);
    enableVoteShare(page, 75);
    page.click('.manual-vote-against-select .v-field');
    page.waitFor('.v-overlay--active .v-list');
    markVoteShareSection(page);
    screenshot.captureRegion(
      'polls/vote_share_requirements/eligible-vs-cast',
      [...optionWindow, '.v-overlay--active .v-list'],
      {
        padding: 32,
        width: 1200,
        height: 1600,
        spotlight: spotlight([...voteShareSection, '.v-overlay--active .v-list'])
      }
    );
  },

  'agree_vote_option': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openAgreeOption(page);
    enableVoteShare(page, 75);
    page.execute('document.activeElement && document.activeElement.blur()');
    markVoteShareSection(page);
    screenshot.captureRegion(
      'polls/vote_share_requirements/agree-vote-option',
      optionWindow,
      {
        padding: 32,
        width: 1200,
        height: 1600,
        spotlight: spotlight(voteShareSection)
      }
    );
  },

  'first_vote_breakdown': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openVoteSharePoll(page, 2);
    screenshot.captureRegion(
      'polls/vote_share_requirements/first-vote-breakdown',
      ['.poll-created .poll-common-card__title', '.poll-created .poll-common-chart-panel', '.poll-created .action-dock'],
      {
        padding: 32,
        width: 1200,
        height: 1800,
        clearSelection: true,
        spotlight: spotlight(['.manual-pass-requirements'])
      }
    );
  },

  'final_vote_breakdown': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openVoteSharePoll(page, 5);
    screenshot.captureRegion(
      'polls/vote_share_requirements/final-vote-breakdown',
      ['.poll-created .poll-common-card__title', '.poll-created .poll-common-chart-panel', '.poll-created .action-dock'],
      {
        padding: 32,
        width: 1200,
        height: 1800,
        clearSelection: true,
        spotlight: spotlight(['.manual-pass-requirements'])
      }
    );
  }
};
