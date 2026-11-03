import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

const SUGGESTIONS = '.v-overlay--active .v-list:has(.recipients-autocomplete-suggestion)';

function spotlight(selector) {
  return {selector, padding: 14, radius: 16, opacity: 0.4, outlineWidth: 0};
}

async function openInvitePoll(page) {
  await page.goto('/dev/setup_manual_oatmilk_invite_poll')
  await expect(page.locator('.poll-created').first()).toBeVisible()
  await expectLabel(page.locator('.poll-created'), 'Approve the bottle trial responsibilities')
}

async function openRunningPoll(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers')
  await page.evaluate("document.querySelector('.topic-item__load-more button')?.click()")
  await expect(page.locator('.poll-created').first()).toBeVisible()
  await expectLabel(page.locator('.poll-created'), 'Run a six-week returnable bottle trial')
}

async function openAddVoters(page, invitePoll = true, height = 700) {
  await page.setViewportSize({ width: 1100, height: height })
  if (invitePoll) openInvitePoll(page); else openRunningPoll(page);
  await page.locator('.action-dock__button--announce_poll').click()
}

async function chooseAudience(page, label) {
  await page.locator('.poll-members-form .recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.v-overlay--active .recipients-autocomplete-suggestion').first()).toBeVisible()
  await page.evaluate(`Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion--group')).find(el => el.textContent.includes(${JSON.stringify(label)})).click()`)
  await expect(page.locator('.poll-members-form .chip--select-multi').first()).toBeVisible()
  await expect(page.locator('.poll-members-form .common-notifications-count').first()).toBeVisible()
}

async function invitationMessage(page) {
  await page.locator('.poll-members-form textarea').evaluate((textarea, value) => {
    Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set.call(textarea, value)
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }, 'Please confirm these responsibilities by Friday. If you see a gap in the plan, add a comment before voting.')
  await page.locator('.poll-members-form .v-card-title').click()
  await expect(page.locator(SUGGESTIONS)).toHaveCount(0)
}

async function openSpecifiedVotersForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_delegate_poll')
  await expectLabel(page.locator('.context-panel__heading'), 'Weekly production schedule')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.decision-tools-card__template--consent').click()
  await expect(page.locator('.poll-common-form').first()).toBeVisible()
  await page.evaluate("document.querySelector('.poll-common-settings__specified-voters-only input').click()")
  await expect(page.locator('.poll-common-settings__specified-voters-only.v-selection-control--dirty').first()).toBeVisible()
}

test('proposal_invite', async ({ page, manual: screenshot }) => {
  // A taller viewport keeps the suggestions below the field instead of over the dialog title.
  await openAddVoters(page, true, 1000);
  await page.locator('.poll-members-form .recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.v-overlay--active .recipients-autocomplete-suggestion').first()).toBeVisible()
  await expectLabel(page.locator(SUGGESTIONS), 'Delegates of Oatmilk Cooperative')
  await expectLabel(page.locator(SUGGESTIONS), 'Oatmilk Cooperative chat')
  await expectLabel(page.locator(SUGGESTIONS), 'Bottle Trial Board')
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite',
    ['.poll-members-form', SUGGESTIONS],
    {width: 1100, height: 1000, padding: 24, spotlight: {selectors: ['.poll-members-form .recipients-autocomplete', SUGGESTIONS], padding: 12, radius: 16, opacity: 0.3, outlineWidth: 0}}
  );
});

test('proposal_invite_members', async ({ page, manual: screenshot }) => {
  await openAddVoters(page);
  await chooseAudience(page, 'Oatmilk Cooperative');
  await invitationMessage(page);
  await expectLabel(page.locator('.poll-members-form .common-notifications-count'), '3')
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_members',
    ['.poll-members-form'],
    {width: 1100, height: 700, padding: 24, spotlight: spotlight('.poll-members-form .recipients-autocomplete')}
  );
});

test('proposal_invite_expand', async ({ page, manual: screenshot }) => {
  await openAddVoters(page);
  await chooseAudience(page, 'Oatmilk Cooperative');
  await invitationMessage(page);
  await page.locator('.poll-members-form .chip--select-multi').click()
  await expectLabel(page.locator('.poll-members-form .recipients-autocomplete'), 'Samira Patel')
  await page.evaluate(`Array.from(document.querySelectorAll('.poll-members-form .chip--select-multi')).find(el => el.textContent.includes('Samira Patel')).classList.add('manual-remove-recipient')`)
  await page.locator('.poll-members-form .v-card-title').click()
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_expand',
    ['.poll-members-form'],
    {width: 1100, height: 700, padding: 24, spotlight: spotlight('.poll-members-form .recipients-autocomplete')}
  );
  await page.locator('.manual-remove-recipient .v-chip__close').click()
  await expect(page.locator('.manual-remove-recipient')).toHaveCount(0)
  await expect(page.locator('.poll-members-form .chip--select-multi')).toHaveCount(2)
});

test('proposal_invite_guest', async ({ page, manual: screenshot }) => {
  await openAddVoters(page);
  await page.locator('.poll-members-form .recipients-autocomplete input[type="text"]').fill('Samira')
  await expect(page.locator('.v-overlay--active .recipients-autocomplete-suggestion').first()).toBeVisible()
  await page.evaluate(`Array.from(document.querySelectorAll('.v-overlay--active .recipients-autocomplete-suggestion')).find(el => el.textContent.includes('Samira Patel')).click()`)
  await expectLabel(page.locator('.poll-members-form .chip--select-multi'), 'Samira Patel')
  await page.locator('.poll-members-form .recipients-autocomplete input[type="text"]').pressSequentially('advisor@cafecircle.example')
  await page.locator('.v-overlay--active .recipients-autocomplete-suggestion').click()
  await expectLabel(page.locator('.poll-members-form .recipients-autocomplete'), 'advisor@cafecircle.example')
  await invitationMessage(page);
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_guest',
    ['.poll-members-form'],
    {padding: 24, width: 1100, height: 700}
  );
});

test('invited_people_only', async ({ page, manual: screenshot }) => {
  await openSpecifiedVotersForm(page);
  await page.evaluate("const radio = document.querySelector('.poll-common-settings__specified-voters-only'); radio.closest('.v-radio-group').classList.add('manual-who-can-vote')")
  await screenshot.captureElement('polls/manage_voters/invited-people-only', '.manual-who-can-vote', {width: 1100, height: 800});
});

test('proposal_after_start', async ({ page, manual: screenshot }) => {
  await openRunningPoll(page);
  await expectLabel(page.locator('.poll-created .action-dock__button--announce_poll'), 'Manage voters')
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
  await expect(page.locator('.poll-members-form__list .poll-members-form__remove').first()).toBeVisible()
  await page.evaluate("const row = Array.from(document.querySelectorAll('.poll-members-form__list .v-list-item')).find(el => el.textContent.includes('Samira Patel')); row.classList.add('manual-remove-voter-row'); row.querySelector('.poll-members-form__remove').classList.add('manual-remove-voter')")
  await expect(page.locator('.manual-remove-voter').first()).toBeVisible()
  await screenshot.captureRegion(
    'polls/manage_voters/proposal_invite_remove',
    ['.poll-members-form'],
    {width: 1100, height: 700, padding: 24, spotlight: spotlight('.manual-remove-voter-row')}
  );
});

test('proposal_remind', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1100, height: 850 })
  await openRunningPoll(page);
  await page.locator('.poll-created .poll-common-vote-form__button--agree').click()
  await page.locator('.poll-created .poll-common-vote-form__reason [contenteditable=true]').fill('The collection and washing responsibilities are clear.')
  await page.locator('.poll-created .poll-common-vote-form__submit').click()
  await expect(page.locator('.poll-created .poll-common-current-vote').first()).toBeVisible()
  await page.locator('.action-dock__button--remind_poll').click()
  await page.locator('.poll-remind .recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.v-overlay--active .recipients-autocomplete-suggestion').first()).toBeVisible()
  await page.locator('.v-overlay--active .recipients-autocomplete-suggestion--voters_uncast').click()
  await expect(page.locator('.poll-remind .chip--select-multi').first()).toBeVisible()
  await page.locator('.poll-remind textarea').evaluate((textarea, value) => {
    Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set.call(textarea, value)
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }, 'Please vote by Friday so we can confirm the cafe collection schedule before the trial starts.')
  await page.locator('.poll-remind .v-card-title').click()
  await expect(page.locator('.poll-remind .recipients-autocomplete .v-field-label--floating').first()).toBeVisible()
  await expect(page.locator('.poll-remind .v-textarea .v-field-label--floating').first()).toBeVisible()
  const labels = await page.evaluate(() => {
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
