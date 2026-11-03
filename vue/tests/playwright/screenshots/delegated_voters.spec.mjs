import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

function spotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

async function openMembers(page, scenario = 'setup_manual_oatmilk_delegates') {
  await page.goto(`/dev/${scenario}`)
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page-members-tab').click()
  await expect(page.locator('.members-panel').first()).toBeVisible()
  await expectLabel(page.locator('.members-panel'), 'Samira Patel')
}

async function openSamiraMenu(page) {
  await openMembers(page, 'setup_manual_oatmilk_group');
  await page.evaluate("Array.from(document.querySelectorAll('.members-panel .v-list-item')).find(el => el.textContent.includes('Samira Patel') && el.querySelector('.membership-dropdown__button')).querySelector('.membership-dropdown__button').click()")
  await expect(page.locator('.v-overlay .group-actions-dropdown__menu-content').first()).toBeVisible()
}

async function openProposalForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_delegate_poll')
  await expectLabel(page.locator('.context-panel__heading'), 'Weekly production schedule')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.decision-tools-card__template--check').click()
  await page.locator('.poll-common-form-fields__title input').fill('Approve reusable bottle pilot')
  await page.locator('.poll-common-form-fields__details [contenteditable=true]').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('delegate-proposal', [
    'Invite the cooperative delegates to decide whether to begin the returnable bottle pilot.',
    'The proposal covers the cafe collection schedule, washing checks, deposit guidance, and reporting responsibilities.',
    'Delegates should consult the members they represent and explain any concern in their vote reason.'
  ]))
  // Click the input itself: longer translated text moves the radio, and a click
  // on its wrapper can land on another element.
  await page.evaluate("document.querySelector('.poll-common-settings__specified-voters-only input').click()")
  await expect(page.locator('.poll-common-settings__specified-voters-only.v-selection-control--dirty').first()).toBeVisible()
}

test('make_delegate', async ({ page, manual: screenshot }) => {
  await openSamiraMenu(page);
  await expectLabel(page.locator('.v-overlay .membership-dropdown__make-delegate'), 'Make delegate')
  await screenshot.capture('groups/delegated_voters/member_make_delegate', {
    spotlight: spotlight('.v-overlay .membership-dropdown__make-delegate')
  });
});

test('invited_people_only', async ({ page, manual: screenshot }) => {
  await openProposalForm(page);
  await expectLabel(page.locator('.poll-common-form'), 'Selected people only')
  await screenshot.captureElement('groups/delegated_voters/poll_invited_people_only', '.poll-common-form', {
    width: 1100,
    height: 1900,
    spotlight: {selector: '.poll-common-settings__specified-voters-only', padding: 10, radius: 12}
  });
});

test('invite_delegates', async ({ page, manual: screenshot }) => {
  await openProposalForm(page);
  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-members-form').first()).toBeVisible()
  await page.locator('.poll-members-form .recipients-autocomplete input[type="text"]').click()
  await expect(page.locator('.recipients-autocomplete-suggestion').first()).toBeVisible()
  await page.evaluate("document.querySelector('.recipients-autocomplete-suggestion--delegates').classList.add('manual-delegates-option')")
  await page.locator('.manual-delegates-option').hover()
  await screenshot.capture('groups/delegated_voters/poll_invite_delegates_group', {height: 650});
});

test('filter_delegates', async ({ page, manual: screenshot }) => {
  await openMembers(page);
  await page.locator('.members-panel__filters').click()
  await expect(page.locator('.v-overlay .members-panel__filters-delegates').first()).toBeVisible()
  await screenshot.capture('groups/delegated_voters/members_list_delegates', {
    spotlight: spotlight('.v-overlay .members-panel__filters-delegates')
  });
});
