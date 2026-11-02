import { test, expect } from '../screenshotFixtures.mjs';

async function spotlight(selectors, padding = 16) {
  return {selectors, padding, radius: 16, opacity: 0.4, outlineWidth: 0};
}

// Opens the proposal used in the results screenshots, so the whole example
// follows one poll and its Agree option.
async function openProposalForm(page) {
  await page.resizeWindow(1200, 1600);
  await page.loadPath('setup_manual_oatmilk_quorum?view=edit');
  await page.waitFor('.poll-common-form-fields__title input');
  await page.execute(`
    const heading = document.querySelector('.poll-common-form .poll-common-form__options-heading');
    heading.classList.add('manual-options-heading');
    const options = Array.from(document.querySelectorAll('.poll-common-form .v-list-item'));
    document.querySelector('.poll-common-form .poll-common-form__option--agree').classList.add('manual-agree-option');
    options[options.length - 1].classList.add('manual-last-option');
  `);
  await page.waitFor('.manual-agree-option');
}

async function openAgreeOption(page) {
  await openProposalForm(page);
  await page.clickAndWait('.manual-agree-option .poll-common-form__edit-option', '.poll-common-option-form');
  await markVoteShareSection(page);
}

// Vue re-renders these fields when they change, which drops added classes, so mark them again after each change.
async function markVoteShareSection(page) {
  await page.execute(`
    const heading = document.querySelector('.poll-common-option-form .poll-option-form__vote-share-heading');
    heading.classList.add('manual-vote-share-heading');
    heading.nextElementSibling.classList.add('manual-vote-share-checkbox');
    heading.nextElementSibling.nextElementSibling.classList.add('manual-vote-share-fields');
    document.querySelectorAll('.poll-common-option-form .v-select').item(1).classList.add('manual-vote-against-select');
  `);
}

async function enableVoteShare(page, percent) {
  await page.click('.manual-vote-share-checkbox .v-selection-control__wrapper');
  await page.pause(200);
  await markVoteShareSection(page);
  await page.fillIn('.manual-vote-share-fields .v-number-input input', String(percent));
  await markVoteShareSection(page);
  await page.click('.manual-vote-against-select .v-field');
  await page.waitFor('.v-overlay--active .v-list');
  await page.click('.v-overlay--active .poll-option-form__test-against--voter_percent');
  await page.pause(300);
  await markVoteShareSection(page);
  await page.expectText('.manual-vote-against-select', 'Eligible voters');
}

async function openVoteSharePoll(page, votes) {
  await page.loadPath(`setup_manual_oatmilk_quorum?vote_share=1&votes=${votes}`);
  await page.waitFor('.poll-created .poll-common-chart-panel');
  await page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
  await page.expectText('.poll-created', `${votes} of 5 votes cast (${votes * 20}% participation)`);
  await page.execute("document.querySelector('.poll-created .poll-common-chart-panel .v-alert').classList.add('manual-pass-requirements')");
  await page.pause(400);
}

// The option window fits on screen, so show all of it with the relevant part spotlighted.
const optionWindow = ['.poll-common-option-form', '.poll-option-form__done-btn'];
const voteShareSection = ['.manual-vote-share-heading', '.manual-vote-share-checkbox', '.manual-vote-share-fields'];

test('edit_highlight_on_option', async ({ lmo: page, manual: screenshot }) => {
  await openProposalForm(page);
  await screenshot.captureRegion(
    'polls/vote_share_requirements/edit-highlight-on-option',
    ['.poll-common-form > .v-card-title', '.manual-options-heading', '.manual-last-option', '.poll-common-form__add-option-btn'],
    {
      padding: 32,
      width: 1200,
      height: 1600,
      spotlight: spotlight(['.manual-agree-option .poll-common-form__edit-option'], 10)
    }
  );
});

test('eligible_vs_cast', async ({ lmo: page, manual: screenshot }) => {
  await openAgreeOption(page);
  await enableVoteShare(page, 75);
  await page.click('.manual-vote-against-select .v-field');
  await page.waitFor('.v-overlay--active .v-list');
  await markVoteShareSection(page);
  await screenshot.captureRegion(
    'polls/vote_share_requirements/eligible-vs-cast',
    [...optionWindow, '.v-overlay--active .v-list'],
    {
      padding: 32,
      width: 1200,
      height: 1600,
      spotlight: spotlight([...voteShareSection, '.v-overlay--active .v-list'])
    }
  );
});

test('agree_vote_option', async ({ lmo: page, manual: screenshot }) => {
  await openAgreeOption(page);
  await enableVoteShare(page, 75);
  await page.execute('document.activeElement && document.activeElement.blur()');
  await markVoteShareSection(page);
  await screenshot.captureRegion(
    'polls/vote_share_requirements/agree-vote-option',
    optionWindow,
    {
      padding: 32,
      width: 1200,
      height: 1600,
      spotlight: spotlight(voteShareSection)
    }
  );
});

test('first_vote_breakdown', async ({ lmo: page, manual: screenshot }) => {
  await openVoteSharePoll(page, 2);
  await screenshot.captureElement(
    'polls/vote_share_requirements/first-vote-breakdown',
    '.poll-created',
    {
      width: 1600,
      height: 1400,
      clearSelection: true,
      spotlight: spotlight(['.manual-pass-requirements'])
    }
  );
});

test('final_vote_breakdown', async ({ lmo: page, manual: screenshot }) => {
  await openVoteSharePoll(page, 5);
  await screenshot.captureElement(
    'polls/vote_share_requirements/final-vote-breakdown',
    '.poll-created',
    {
      width: 1600,
      height: 1400,
      clearSelection: true,
      spotlight: spotlight(['.manual-pass-requirements'])
    }
  );
});
