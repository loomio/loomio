import { test, expect } from '../screenshotFixtures.mjs';

const SUGGESTIONS = '.v-overlay--active .v-list:has(.recipients-autocomplete-suggestion)';

async function spotlight(selector) {
  return {selector, padding: 14, radius: 16, opacity: 0.4, outlineWidth: 0};
}

async function openInvitePoll(page) {
  await page.loadPath('setup_manual_oatmilk_invite_poll');
  await page.waitFor('.poll-created');
  await page.expectText('.poll-created', 'Approve the bottle trial responsibilities');
}

async function openRunningPoll(page) {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  await page.execute("document.querySelector('.topic-item__load-more button')?.click()");
  await page.waitFor('.poll-created');
  await page.expectText('.poll-created', 'Run a six-week returnable bottle trial');
}

async function openAddVoters(page, invitePoll = true, height = 700) {
  await page.resizeWindow(1100, height);
  if (invitePoll) openInvitePoll(page); else openRunningPoll(page);
  await page.clickAndWait('.action-dock__button--announce_poll', '.poll-members-form');
}

async function chooseAudience(page, label) {
  await page.click('.poll-members-form .recipients-autocomplete input[type="text"]');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.execute(`Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion--group')).find(el => el.textContent.includes(${JSON.stringify(label)})).click()`);
  await page.waitFor('.poll-members-form .chip--select-multi');
  await page.waitFor('.poll-members-form .common-notifications-count');
}

async function invitationMessage(page) {
  await page.fillTextarea('.poll-members-form textarea', 'Please confirm these responsibilities by Friday. If you see a gap in the plan, add a comment before voting.');
  await page.click('.poll-members-form .v-card-title');
  await page.expectNoElement(SUGGESTIONS);
}

async function openSpecifiedVotersForm(page) {
  await page.loadPath('setup_manual_oatmilk_delegate_poll');
  await page.expectText('.context-panel__heading', 'Weekly production schedule');
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal');
  await page.click('.decision-tools-card__template--consent');
  await page.waitFor('.poll-common-form');
  await page.execute("document.querySelector('.poll-common-settings__specified-voters-only input').click()");
  await page.waitFor('.poll-common-settings__specified-voters-only.v-selection-control--dirty');
}

test('proposal_invite', async ({ lmo: page, manual: screenshot }) => {
  // A taller viewport keeps the suggestions below the field instead of over the dialog title.
  await openAddVoters(page, true, 1000);
  await page.click('.poll-members-form .recipients-autocomplete input[type="text"]');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.expectText(SUGGESTIONS, 'Delegates of Oatmilk Cooperative');
  await page.expectText(SUGGESTIONS, 'Oatmilk Cooperative chat');
  await page.expectText(SUGGESTIONS, 'Bottle Trial Board');
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite',
    ['.poll-members-form', SUGGESTIONS],
    {width: 1100, height: 1000, padding: 24, spotlight: {selectors: ['.poll-members-form .recipients-autocomplete', SUGGESTIONS], padding: 12, radius: 16, opacity: 0.3, outlineWidth: 0}}
  );
});

test('proposal_invite_members', async ({ lmo: page, manual: screenshot }) => {
  await openAddVoters(page);
  await chooseAudience(page, 'Oatmilk Cooperative');
  await invitationMessage(page);
  await page.expectText('.poll-members-form .common-notifications-count', '3');
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_members',
    ['.poll-members-form'],
    {width: 1100, height: 700, padding: 24, spotlight: spotlight('.poll-members-form .recipients-autocomplete')}
  );
});

test('proposal_invite_expand', async ({ lmo: page, manual: screenshot }) => {
  await openAddVoters(page);
  await chooseAudience(page, 'Oatmilk Cooperative');
  await invitationMessage(page);
  await page.click('.poll-members-form .chip--select-multi');
  await page.expectText('.poll-members-form .recipients-autocomplete', 'Samira Patel');
  await page.execute(`Array.from(document.querySelectorAll('.poll-members-form .chip--select-multi')).find(el => el.textContent.includes('Samira Patel')).classList.add('manual-remove-recipient')`);
  await page.click('.poll-members-form .v-card-title');
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_expand',
    ['.poll-members-form'],
    {width: 1100, height: 700, padding: 24, spotlight: spotlight('.poll-members-form .recipients-autocomplete')}
  );
  await page.click('.manual-remove-recipient .v-chip__close');
  await page.expectNoElement('.manual-remove-recipient');
  await page.expectCount('.poll-members-form .chip--select-multi', 2);
});

test('proposal_invite_guest', async ({ lmo: page, manual: screenshot }) => {
  await openAddVoters(page);
  await page.fillIn('.poll-members-form .recipients-autocomplete input[type="text"]', 'Samira');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.execute(`Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Samira Patel')).click()`);
  await page.expectText('.poll-members-form .chip--select-multi', 'Samira Patel');
  await page.fillIn('.poll-members-form .recipients-autocomplete input[type="text"]', 'advisor@cafecircle.example');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.click('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.expectText('.poll-members-form .recipients-autocomplete', 'advisor@cafecircle.example');
  await invitationMessage(page);
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_guest',
    ['.poll-members-form'],
    {padding: 24, width: 1100, height: 700}
  );
});

test('invited_people_only', async ({ lmo: page, manual: screenshot }) => {
  await openSpecifiedVotersForm(page);
  await page.execute("const radio = document.querySelector('.poll-common-settings__specified-voters-only'); radio.closest('.v-radio-group').classList.add('manual-who-can-vote')");
  await screenshot.captureElement('polls/manage_voters/invited-people-only', '.manual-who-can-vote', {width: 1100, height: 800});
});

test('proposal_after_start', async ({ lmo: page, manual: screenshot }) => {
  await openRunningPoll(page);
  await page.expectText('.poll-created .action-dock__button--announce_poll', 'Manage voters');
  await screenshot.captureRegion('polls/manage_voters/proposal_after_start', ['.poll-created .poll-common-card__title', '.poll-created .action-dock'], {
    width: 1100,
    height: 1800,
    padding: 18,
    clearSelection: true,
    spotlight: spotlight('.poll-created .action-dock__button--announce_poll')
  });
});

test('proposal_invite_remove', async ({ lmo: page, manual: screenshot }) => {
  await openAddVoters(page, false);
  await page.waitFor('.poll-members-form__list .poll-members-form__remove');
  await page.execute("const row = Array.from(document.querySelectorAll('.poll-members-form__list .v-list-item')).find(el => el.textContent.includes('Samira Patel')); row.classList.add('manual-remove-voter-row'); row.querySelector('.poll-members-form__remove').classList.add('manual-remove-voter')");
  await page.waitFor('.manual-remove-voter');
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_remove',
    ['.poll-members-form'],
    {width: 1100, height: 700, padding: 24, spotlight: spotlight('.manual-remove-voter-row')}
  );
});

test('proposal_remind', async ({ lmo: page, manual: screenshot }) => {
  await page.resizeWindow(1100, 850);
  await openRunningPoll(page);
  await page.click('.poll-created .poll-common-vote-form__button--agree');
  await page.fillIn('.poll-created .poll-common-vote-form__reason [contenteditable=true]', 'The collection and washing responsibilities are clear.');
  await page.click('.poll-created .poll-common-vote-form__submit');
  await page.waitFor('.poll-created .poll-common-current-vote');
  await page.clickAndWait('.action-dock__button--remind_poll', '.poll-remind');
  await page.click('.poll-remind .recipients-autocomplete input[type="text"]');
  await page.waitFor('.v-overlay--active .recipients-autocomplete-suggestion');
  await page.click('.v-overlay--active .recipients-autocomplete-suggestion--voters_uncast');
  await page.waitFor('.poll-remind .chip--select-multi');
  await page.fillTextarea('.poll-remind textarea', 'Please vote by Friday so we can confirm the cafe collection schedule before the trial starts.');
  await page.click('.poll-remind .v-card-title');
  await page.waitFor('.poll-remind .recipients-autocomplete .v-field-label--floating');
  await page.waitFor('.poll-remind .v-textarea .v-field-label--floating');
  const labels = await page.execute(() => {
    const dialog = document.querySelector('.poll-remind');
    const labels = Array.from(document.querySelectorAll('.poll-remind .v-field-label--floating'))
      .filter(label => getComputedStyle(label).visibility === 'visible');
    const clipped = labels.filter(label => {
      const bounds = label.getBoundingClientRect();
      for (let parent = label.parentElement; dialog.contains(parent); parent = parent.parentElement) {
        if (!['hidden', 'clip', 'auto', 'scroll'].includes(getComputedStyle(parent).overflowY)) continue;
        const top = parent.getBoundingClientRect().top + parent.clientTop;
        if (bounds.top < top - 0.5 || bounds.bottom > top + parent.clientHeight + 0.5) return true;
      }
      return false;
    });
    return {count: labels.length, clipped: clipped.map(label => label.textContent.trim())};
  });
  expect(labels.count, 'Both floating field labels are visible').toBe(2);
  expect(labels.clipped, 'Floating labels fit inside their dialog containers').toEqual([]);
  await screenshot.captureRegion('polls/manage_voters/proposal_remind', ['.poll-remind'], {width: 1100, height: 850, padding: 32});
});
