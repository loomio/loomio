import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

function spotlight(selectors, padding = 16) {
  return { selectors, padding, radius: 16, opacity: 0.4, outlineWidth: 0 };
}

const agreeOption = '.poll-common-form .poll-common-form__option--agree';
const testAgainst = '.poll-common-option-form .poll-option-form__test-against';

// Opens the proposal used in the results screenshots, so the whole example
// follows one poll and its Agree option.
async function openProposalForm(page) {
  await page.setViewportSize({ width: 1200, height: 1600 });
  await page.goto('/dev/setup_manual_oatmilk_quorum?view=edit');
  await expect(page.locator(agreeOption)).toBeVisible();
  // The capture helper takes selectors; give the last list item one.
  await page.locator('.poll-common-form .v-list-item').last().evaluate(item => item.classList.add('manual-last-option'));
}

async function openAgreeOption(page) {
  await openProposalForm(page);
  await page.locator(`${agreeOption} .poll-common-form__edit-option`).click();
}

async function openTestAgainst(page) {
  await page.locator(`${testAgainst} .v-field`).click();
  await expect(page.locator('.v-overlay--active .v-list')).toBeVisible();
}

async function enableVoteShare(page, percent) {
  const form = page.locator('.poll-common-option-form');
  await form.locator('.poll-option-form__vote-share-enabled input').check();
  await form.locator('.poll-option-form__test-percent input').fill(String(percent));
  await openTestAgainst(page);
  await page.locator('.v-overlay--active .poll-option-form__test-against--voter_percent').click();
  await expectLabel(page.locator(testAgainst), 'Eligible voters');
}

async function openVoteSharePoll(page, votes) {
  await page.goto(`/dev/setup_manual_oatmilk_quorum?vote_share=1&votes=${votes}`);
  const poll = page.locator('.poll-created');
  await expect(poll.locator('.poll-common-chart-panel__requirements')).toBeVisible();
  await expectLabel(poll, 'Run a six-week returnable bottle trial');
  await expectLabel(poll, `${votes} of 5 votes cast (${votes * 20}% participation)`);
}

// The option window fits on screen, so show all of it with the relevant part spotlighted.
const optionWindow = ['.poll-common-option-form', '.poll-option-form__done-btn'];
const voteShareSection = [
  '.poll-common-option-form .poll-option-form__vote-share-heading',
  '.poll-common-option-form .poll-option-form__vote-share-enabled',
  '.poll-common-option-form .poll-option-form__vote-share-fields'
];
const passRequirements = '.poll-created .poll-common-chart-panel__requirements';

test('edit_highlight_on_option', async ({ page, manual: screenshot }) => {
  await openProposalForm(page);
  await screenshot.captureRegion(
    'polls/vote_share_requirements/edit-highlight-on-option',
    ['.poll-common-form > .v-card-title', '.poll-common-form .poll-common-form__options-heading', '.manual-last-option', '.poll-common-form__add-option-btn'],
    {
      padding: 32,
      width: 1200,
      height: 1600,
      spotlight: spotlight([`${agreeOption} .poll-common-form__edit-option`], 10)
    }
  );
});

test('eligible_vs_cast', async ({ page, manual: screenshot }) => {
  await openAgreeOption(page);
  await enableVoteShare(page, 75);
  await openTestAgainst(page);
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
  await page.evaluate(() => document.activeElement?.blur());
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

for (const [name, votes] of [['first_vote_breakdown', 2], ['final_vote_breakdown', 5]]) {
  test(name, async ({ page, manual: screenshot }) => {
    await openVoteSharePoll(page, votes);
    await screenshot.captureElement(
      `polls/vote_share_requirements/${name.replaceAll('_', '-')}`,
      '.poll-created',
      {
        width: 1600,
        height: 1400,
        clearSelection: true,
        spotlight: spotlight([passRequirements])
      }
    );
  });
}
