import { test, expect } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function spotlight(selector) {
  return {
    selector,
    padding: 14,
    radius: 14,
    opacity: 0.4,
    outlineWidth: 0
  };
}

async function openMembers(page, scenario = 'setup_manual_oatmilk_delegates') {
  await page.loadPath(scenario);
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page-members-tab');
  await page.waitFor('.members-panel');
  await page.expectText('.members-panel', 'Samira Patel');
}

async function openSamiraMenu(page) {
  await openMembers(page, 'setup_manual_oatmilk_group');
  await page.execute("Array.from(document.querySelectorAll('.members-panel .v-list-item')).find(el => el.textContent.includes('Samira Patel') && el.querySelector('.membership-dropdown__button')).querySelector('.membership-dropdown__button').click()");
  await page.waitFor('.v-overlay .group-actions-dropdown__menu-content');
}

async function openProposalForm(page) {
  await page.loadPath('setup_manual_oatmilk_delegate_poll');
  await page.expectText('.context-panel__heading', 'Weekly production schedule');
  await page.clickAndWait('.activity-panel__add-poll', '.decision-tools-card__poll-type--proposal');
  await page.clickAndWait('.decision-tools-card__poll-type--proposal', '.poll-common-form-fields__title input');
  await page.fillIn('.poll-common-form-fields__title input', 'Approve reusable bottle pilot');
  await page.fillRichText('.poll-common-form-fields__details [contenteditable=true]', richText.context('delegate-proposal', [
    'Invite the cooperative delegates to decide whether to begin the returnable bottle pilot.',
    'The proposal covers the cafe collection schedule, washing checks, deposit guidance, and reporting responsibilities.',
    'Delegates should consult the members they represent and explain any concern in their vote reason.'
  ]));
  // Click the input itself: longer translated text moves the radio, and a click
  // on its wrapper can land on another element.
  await page.execute("document.querySelector('.poll-common-settings__specified-voters-only input').click()");
  await page.waitFor('.poll-common-settings__specified-voters-only.v-selection-control--dirty');
}

test('make_delegate', async ({ lmo: page, manual: screenshot }) => {
  await openSamiraMenu(page);
  await page.expectText('.v-overlay .membership-dropdown__make-delegate', 'Make delegate');
  await screenshot.capture('groups/delegated_voters/member_make_delegate', {
    spotlight: spotlight('.v-overlay .membership-dropdown__make-delegate')
  });
});

test('invited_people_only', async ({ lmo: page, manual: screenshot }) => {
  await openProposalForm(page);
  await page.expectText('.poll-common-form', 'Selected people only');
  await screenshot.captureElement('groups/delegated_voters/poll_invited_people_only', '.poll-common-form', {
    width: 1100,
    height: 1900,
    spotlight: {selector: '.poll-common-settings__specified-voters-only', padding: 10, radius: 12}
  });
});

test('invite_delegates', async ({ lmo: page, manual: screenshot }) => {
  await openProposalForm(page);
  await page.click('.poll-common-form__submit');
  await page.waitFor('.poll-members-form');
  await page.click('.poll-members-form .recipients-autocomplete input[type="text"]');
  await page.waitFor('.recipients-autocomplete-suggestion');
  await page.pause(300);
  await page.execute("document.querySelector('.recipients-autocomplete-suggestion--delegates').classList.add('manual-delegates-option')");
  await page.mouseOver('.manual-delegates-option');
  await screenshot.capture('groups/delegated_voters/poll_invite_delegates_group', {height: 650});
});

test('filter_delegates', async ({ lmo: page, manual: screenshot }) => {
  await openMembers(page);
  await page.click('.members-panel__filters');
  await page.waitFor('.v-overlay .members-panel__filters-delegates');
  await screenshot.capture('groups/delegated_voters/members_list_delegates', {
    spotlight: spotlight('.v-overlay .members-panel__filters-delegates')
  });
});
