import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

function spotlight(selectors, padding = 16) {
  return {selectors, padding, radius: 16, opacity: 0.4, outlineWidth: 0};
}

// Opens the proposal used in the results screenshots, so the whole example
// follows one poll and its Agree option.
async function openProposalForm(page) {
  await page.setViewportSize({ width: 1200, height: 1600 })
  await page.goto('/dev/setup_manual_oatmilk_quorum?view=edit')
  await expect(page.locator('.poll-common-form-fields__title input').first()).toBeVisible()
  await page.evaluate(`
    const heading = document.querySelector('.poll-common-form .poll-common-form__options-heading');
    heading.classList.add('manual-options-heading');
    const options = Array.from(document.querySelectorAll('.poll-common-form .v-list-item'));
    document.querySelector('.poll-common-form .poll-common-form__option--agree').classList.add('manual-agree-option');
    options[options.length - 1].classList.add('manual-last-option');
  `)
  await expect(page.locator('.manual-agree-option').first()).toBeVisible()
}

async function openAgreeOption(page) {
  await openProposalForm(page);
  await page.locator('.manual-agree-option .poll-common-form__edit-option').click()
  await markVoteShareSection(page);
}

// Vue re-renders these fields when they change, which drops added classes, so mark them again after each change.
async function markVoteShareSection(page) {
  await page.evaluate(`
    const heading = document.querySelector('.poll-common-option-form .poll-option-form__vote-share-heading');
    heading.classList.add('manual-vote-share-heading');
    heading.nextElementSibling.classList.add('manual-vote-share-checkbox');
    heading.nextElementSibling.nextElementSibling.classList.add('manual-vote-share-fields');
    document.querySelectorAll('.poll-common-option-form .v-select').item(1).classList.add('manual-vote-against-select');
  `)
}

async function enableVoteShare(page, percent) {
  await page.locator('.manual-vote-share-checkbox .v-selection-control__wrapper').click()
  await markVoteShareSection(page);
  await page.locator('.manual-vote-share-fields .v-number-input input').fill(String(percent))
  await markVoteShareSection(page);
  await page.locator('.manual-vote-against-select .v-field').click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
  await page.locator('.v-overlay--active .poll-option-form__test-against--voter_percent').click()
  await markVoteShareSection(page);
  await expectLabel(page.locator('.manual-vote-against-select'), 'Eligible voters')
}

async function openVoteSharePoll(page, votes) {
  await page.goto(`/dev/setup_manual_oatmilk_quorum?vote_share=1&votes=${votes}`)
  await expect(page.locator('.poll-created .poll-common-chart-panel').first()).toBeVisible()
  await expectLabel(page.locator('.poll-created'), 'Run a six-week returnable bottle trial')
  await expectLabel(page.locator('.poll-created'), `${votes} of 5 votes cast (${votes * 20}% participation)`)
  await page.evaluate("document.querySelector('.poll-created .poll-common-chart-panel .v-alert').classList.add('manual-pass-requirements')")
}

// The option window fits on screen, so show all of it with the relevant part spotlighted.
const optionWindow = ['.poll-common-option-form', '.poll-option-form__done-btn'];
const voteShareSection = ['.manual-vote-share-heading', '.manual-vote-share-checkbox', '.manual-vote-share-fields'];

test('edit_highlight_on_option', async ({ page, manual: screenshot }) => {
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

test('eligible_vs_cast', async ({ page, manual: screenshot }) => {
  await openAgreeOption(page);
  await enableVoteShare(page, 75);
  await page.locator('.manual-vote-against-select .v-field').click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
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

test('agree_vote_option', async ({ page, manual: screenshot }) => {
  await openAgreeOption(page);
  await enableVoteShare(page, 75);
  await page.evaluate('document.activeElement && document.activeElement.blur()')
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

test('first_vote_breakdown', async ({ page, manual: screenshot }) => {
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

test('final_vote_breakdown', async ({ page, manual: screenshot }) => {
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
