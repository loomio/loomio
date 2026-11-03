import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { voteOption } from '../helpers/polls.mjs';

const SUGGESTIONS = '.v-overlay--active .v-list:has(.recipients-autocomplete-suggestion)';
const voters = page => page.locator('.poll-members-form');
const recipientsInput = scope => scope.locator('.recipients-autocomplete input[type="text"]');
const suggestions = page => page.locator('.v-overlay--active .recipients-autocomplete-suggestion');

function spotlight(selector) {
  return { selector, padding: 14, radius: 16, opacity: 0.4, outlineWidth: 0 };
}

// Sets a textarea's text without focusing or scrolling it, so the dialog's
// layout matches what a reader sees after typing and moving on.
async function setText(textarea, value) {
  await textarea.evaluate((element, text) => {
    Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set.call(element, text);
    element.dispatchEvent(new Event('input', { bubbles: true }));
  }, value);
}

async function openInvitePoll(page) {
  await page.goto('/dev/setup_manual_oatmilk_invite_poll');
  await expectLabel(page.locator('.poll-created'), 'Approve the bottle trial responsibilities');
}

async function openRunningPoll(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion');
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers');
  // Older items load on request; the poll may be among them.
  const loadMore = page.locator('.topic-item__load-more button');
  if (await loadMore.count()) { await loadMore.first().click(); }
  await expectLabel(page.locator('.poll-created'), 'Run a six-week returnable bottle trial');
}

async function openAddVoters(page, invitePoll = true, height = 700) {
  await page.setViewportSize({ width: 1100, height: height });
  if (invitePoll) { await openInvitePoll(page); } else { await openRunningPoll(page); }
  await page.locator('.action-dock__button--announce_poll').click();
}

async function openSuggestions(page) {
  await recipientsInput(voters(page)).click();
  // Any suggestion shows the list has loaded.
  await expect(suggestions(page).first()).toBeVisible();
}

async function chooseAudience(page, label) {
  await openSuggestions(page);
  await page.locator('.v-overlay--active .recipients-autocomplete-suggestion--group', { hasText: label }).click();
  await expect(voters(page).locator('.chip--select-multi')).toBeVisible();
  await expect(voters(page).locator('.common-notifications-count')).toBeVisible();
}

async function invitationMessage(page) {
  await setText(voters(page).locator('textarea'), 'Please confirm these responsibilities by Friday. If you see a gap in the plan, add a comment before voting.');
  await voters(page).locator('.v-card-title').click();
  await expect(page.locator(SUGGESTIONS)).toHaveCount(0);
}

async function openSpecifiedVotersForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_delegate_poll');
  await expectLabel(page.locator('.context-panel__heading'), 'Weekly production schedule');
  await page.locator('.activity-panel__add-poll').click();
  await page.locator('.decision-tools-card__template--consent').click();
  await page.locator('.poll-common-settings__specified-voters-only input').check();
}

test('proposal_invite', async ({ page, manual: screenshot }) => {
  // A taller viewport keeps the suggestions below the field instead of over the dialog title.
  await openAddVoters(page, true, 1000);
  await openSuggestions(page);
  for (const label of ['Delegates of Oatmilk Cooperative', 'Oatmilk Cooperative chat', 'Bottle Trial Board']) {
    await expectLabel(page.locator(SUGGESTIONS), label);
  }
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite',
    ['.poll-members-form', SUGGESTIONS],
    { width: 1100, height: 1000, padding: 24, spotlight: { selectors: ['.poll-members-form .recipients-autocomplete', SUGGESTIONS], padding: 12, radius: 16, opacity: 0.3, outlineWidth: 0 } }
  );
});

test('proposal_invite_members', async ({ page, manual: screenshot }) => {
  await openAddVoters(page);
  await chooseAudience(page, 'Oatmilk Cooperative');
  await invitationMessage(page);
  await expectLabel(voters(page).locator('.common-notifications-count'), '3');
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_members',
    ['.poll-members-form'],
    { width: 1100, height: 700, padding: 24, spotlight: spotlight('.poll-members-form .recipients-autocomplete') }
  );
});

test('proposal_invite_expand', async ({ page, manual: screenshot }) => {
  await openAddVoters(page);
  await chooseAudience(page, 'Oatmilk Cooperative');
  await invitationMessage(page);
  await voters(page).locator('.chip--select-multi').click();
  const samira = voters(page).locator('.chip--select-multi', { hasText: 'Samira Patel' });
  await expectLabel(voters(page).locator('.recipients-autocomplete'), 'Samira Patel');
  await voters(page).locator('.v-card-title').click();
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_expand',
    ['.poll-members-form'],
    { width: 1100, height: 700, padding: 24, spotlight: spotlight('.poll-members-form .recipients-autocomplete') }
  );
  await samira.locator('.v-chip__close').click();
  await expect(samira).toHaveCount(0);
  await expect(voters(page).locator('.chip--select-multi')).toHaveCount(2);
});

test('proposal_invite_guest', async ({ page, manual: screenshot }) => {
  await openAddVoters(page);
  await recipientsInput(voters(page)).fill('Samira');
  await suggestions(page).filter({ hasText: 'Samira Patel' }).click();
  await expectLabel(voters(page).locator('.chip--select-multi'), 'Samira Patel');
  await recipientsInput(voters(page)).pressSequentially('advisor@cafecircle.example');
  await suggestions(page).filter({ hasText: 'advisor@cafecircle.example' }).click();
  await expectLabel(voters(page).locator('.recipients-autocomplete'), 'advisor@cafecircle.example');
  await invitationMessage(page);
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_guest',
    ['.poll-members-form'],
    { padding: 24, width: 1100, height: 700 }
  );
});

test('invited_people_only', async ({ page, manual: screenshot }) => {
  await openSpecifiedVotersForm(page);
  await screenshot.captureElement('polls/manage_voters/invited-people-only', '.poll-common-form__who-can-vote', { width: 1100, height: 800 });
});

test('proposal_after_start', async ({ page, manual: screenshot }) => {
  await openRunningPoll(page);
  await expectLabel(page.locator('.poll-created .action-dock__button--announce_poll'), 'Manage voters');
  await screenshot.captureRegion('polls/manage_voters/proposal_after_start', ['.poll-created .poll-common-card__title', '.poll-created .action-dock'], {
    width: 1100,
    height: 1800,
    padding: 18,
    clearSelection: true,
    spotlight: spotlight('.poll-created .action-dock__button--announce_poll')
  });
});

test('proposal_invite_remove', async ({ page, manual: screenshot }) => {
  await openAddVoters(page, false);
  const row = voters(page).locator('.poll-members-form__list .v-list-item', { hasText: 'Samira Patel' });
  await expect(row.locator('.poll-members-form__remove')).toBeVisible();
  // The capture helper takes selectors; give the row one.
  await row.evaluate(element => element.classList.add('manual-remove-voter-row'));
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_remove',
    ['.poll-members-form'],
    { width: 1100, height: 700, padding: 24, spotlight: spotlight('.manual-remove-voter-row') }
  );
});

test('proposal_remind', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1100, height: 850 });
  await openRunningPoll(page);
  const poll = page.locator('.poll-created');
  await voteOption(poll, 'agree').click();
  await editor(poll.locator('.poll-common-vote-form__reason')).fill('The collection and washing responsibilities are clear.');
  await poll.locator('.poll-common-vote-form__submit').click();
  await expect(poll.locator('.poll-common-current-vote')).toBeVisible();

  const remind = page.locator('.poll-remind');
  await page.locator('.action-dock__button--remind_poll').click();
  await recipientsInput(remind).click();
  await page.locator('.v-overlay--active .recipients-autocomplete-suggestion--voters_uncast').click();
  await expect(remind.locator('.chip--select-multi')).toBeVisible();
  await setText(remind.locator('textarea'), 'Please vote by Friday so we can confirm the cafe collection schedule before the trial starts.');
  await remind.locator('.v-card-title').click();
  await expect(remind.locator('.recipients-autocomplete .v-field-label--floating').first()).toBeVisible();
  await expect(remind.locator('.v-textarea .v-field-label--floating').first()).toBeVisible();

  // Vuetify keeps hidden copies of its labels, so check the visible floating ones.
  const labels = await remind.evaluate(dialog => {
    const visible = Array.from(dialog.querySelectorAll('.v-field-label--floating'))
      .filter(label => getComputedStyle(label).visibility === 'visible');
    const clipped = visible.filter(label => {
      const bounds = label.getBoundingClientRect();
      for (let parent = label.parentElement; dialog.contains(parent); parent = parent.parentElement) {
        if (!['hidden', 'clip', 'auto', 'scroll'].includes(getComputedStyle(parent).overflowY)) continue;
        const top = parent.getBoundingClientRect().top + parent.clientTop;
        if (bounds.top < top - 0.5 || bounds.bottom > top + parent.clientHeight + 0.5) return true;
      }
      return false;
    });
    return { count: visible.length, clipped: clipped.map(label => label.textContent.trim()) };
  });
  expect(labels.count, 'Both floating field labels are visible').toBe(2);
  expect(labels.clipped, 'Floating labels fit inside their dialog containers').toEqual([]);
  await screenshot.captureRegion('polls/manage_voters/proposal_remind', ['.poll-remind'], { width: 1100, height: 850, padding: 32 });
});
