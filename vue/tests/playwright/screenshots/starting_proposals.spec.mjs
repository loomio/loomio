import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openTemplates(page) {
  await page.goto('/dev/setup_manual_oatmilk_formatting?key=0');
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers');
  await page.locator('.activity-panel__add-poll').click();
  await expect(page.locator('.decision-tools-card__template--consent')).toBeVisible();
}

async function openProposalForm(page) {
  await openTemplates(page);
  await page.locator('.decision-tools-card__template--consent').click();
  await page.locator('.poll-common-form-fields__title input').fill('Approve the returnable bottle trial plan');
  await editor(page.locator('.poll-common-form-fields__details')).evaluate((element, html) => {
    element.focus();
    element.innerHTML = html;
    element.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }));
  }, richText.context('new-proposal', [
      'Approve a six-week returnable bottle trial with three cafe partners and one collection from each cafe every week.',
      'Before launch, confirm the collection schedule, washing checks, bottle deposit guidance, and named responsibilities.',
      'At the end of the trial, review return rates, cleaning time, damaged bottles, and transport costs.'
    ]));
}

const optionsList = page => page.locator('.poll-common-form .poll-common-form__options-list');

async function openPoll(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion');
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers');
  // Earlier items may be folded away.
  const loadMore = page.locator('.topic-item__load-more button');
  if (await loadMore.count()) { await loadMore.click(); }
  await expectLabel(page.locator('.poll-created'), 'Run a six-week returnable bottle trial');
}

async function openPollMenu(page) {
  await openPoll(page);
  await page.locator('.poll-created .action-menu--btn').click();
  await expect(page.locator('.v-overlay--active .v-list')).toBeVisible();
}

test('proposal_templates', async ({ page, manual: screenshot }) => {
  await openTemplates(page);
  await screenshot.captureElement(
    'polls/settings/proposal_templates',
    '.actions-panel',
    {width: 1280, height: 1000}
  );
});

test('proposal_new', async ({ page, manual: screenshot }) => {
  await openProposalForm(page);
  await page.evaluate(`
    const form = document.querySelector('.poll-common-form');
    const wrapper = document.createElement('div');
    wrapper.className = 'manual-proposal-new-capture';
    Object.assign(wrapper.style, {
      position: 'fixed', top: '0', left: '0', width: '100%', zIndex: '9999',
      padding: '24px', background: 'white'
    });
    [
      form.querySelector('.v-card-title'),
      form.querySelector('.poll-template-info-panel'),
      form.querySelector('.poll-common-form-fields__title'),
      form.querySelector('.poll-common-form-fields__details')
    ].forEach(el => wrapper.append(el.cloneNode(true)));
    document.body.append(wrapper);
  `)
  await screenshot.captureElement(
    'polls/settings/proposal_new',
    '.manual-proposal-new-capture',
    {width: 1200, height: 1100}
  );
});

test('vote_options', async ({ page, manual: screenshot }) => {
  await openProposalForm(page);
  await expect(optionsList(page)).toBeVisible();
  await page.evaluate(`
    const heading = document.querySelector('.poll-common-form .poll-common-form__options-heading');
    const list = document.querySelector('.poll-common-form .poll-common-form__options-list');
    const wrapper = document.createElement('div');
    wrapper.className = 'manual-options-capture';
    Object.assign(wrapper.style, {
      position: 'fixed', top: '0', left: '0', width: '100%', zIndex: '9999',
      padding: '16px', background: 'white'
    });
    wrapper.append(heading.cloneNode(true), list.cloneNode(true));
    document.body.append(wrapper);
  `)
  await screenshot.captureElement(
    'polls/settings/vote_options',
    '.manual-options-capture',
    {width: 1200, height: 1200}
  );
});

test('proposal_edit_option', async ({ page, manual: screenshot }) => {
  await openProposalForm(page);
  // The last option, as before.
  await optionsList(page).locator('.poll-common-form__edit-option').last().click();
  await screenshot.captureElement(
    'polls/settings/proposal_edit_option',
    '.poll-common-option-form',
    {width: 1100, height: 1000}
  );
});

test('settings_advanced', async ({ page, manual: screenshot }) => {
  await openProposalForm(page);
  await page.locator('.poll-common-form__more-settings').click();
  await screenshot.captureElement(
    'polls/settings/settings_advanced',
    '.poll-common-form .v-expansion-panel',
    {width: 1100, height: 1600}
  );
});

test('vote_reason_options', async ({ page, manual: screenshot }) => {
  await openProposalForm(page);
  await page.locator('.poll-common-form__more-settings').click();
  await page.locator('.poll-common-form__stance-reason-required .v-field').click();
  await expect(page.locator('.v-overlay--active .v-list')).toBeVisible();
  await page.evaluate(`
    const wrapper = document.createElement('div');
    wrapper.className = 'manual-vote-reason-options-capture';
    Object.assign(wrapper.style, {
      position: 'fixed', top: '0', left: '0', width: '720px', zIndex: '9999',
      padding: '24px', background: 'white'
    });
    wrapper.append(
      document.querySelector('.poll-common-form__stance-reason-required').cloneNode(true),
      document.querySelector('.v-overlay--active .v-list').cloneNode(true)
    );
    document.body.append(wrapper);
  `)
  await screenshot.captureElement(
    'polls/settings/vote_reason_options',
    '.manual-vote-reason-options-capture',
    {width: 900, height: 900}
  );
});

test('proposal_edit', async ({ page, manual: screenshot }) => {
  await openPollMenu(page);
  await screenshot.captureRegion(
    'polls/settings/proposal_edit',
    ['.poll-created .action-dock', '.v-overlay--active .v-list'],
    {padding: 16, width: 1280, height: 1100}
  );
});

test('proposal_notification_history', async ({ page, manual: screenshot }) => {
  await openPollMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--notification_history').click();
  await expectLabel(page.locator('.modal-launcher .v-card'), 'Poll notification history');
  await screenshot.captureElement(
    'polls/settings/proposal_notification_history',
    '.modal-launcher .v-card',
    {width: 1100, height: 900}
  );
});

test('proposal_delete', async ({ page, manual: screenshot }) => {
  await openPollMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--discard_poll').click();
  await screenshot.captureElement(
    'polls/settings/proposal_delete',
    '.confirm-modal',
    {width: 1100, height: 800}
  );
});

test('proposal_print', async ({ page, manual: screenshot }) => {
  await openPoll(page);
  await page.locator('.topic-sidebar .action-dock__button--export_thread').click();
  await expect(page).toHaveURL(/export=1/);
  await expect(page.locator('body')).toBeVisible();
  await screenshot.capture('polls/settings/proposal_print', {
    width: 1280,
    height: 1057
  });
});
