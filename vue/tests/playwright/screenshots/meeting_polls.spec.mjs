import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openPollTemplates(page) {
  await page.goto('/dev/setup_manual_oatmilk_formatting?key=0')
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers')
  await page.locator('.activity-panel__add-poll').click()
  await page.locator('.poll-common-choose-template__poll').click()
  await expectLabel(page.locator('.decision-tools-card__poll-types'), 'Time poll')
  await page.evaluate(`
    document.querySelectorAll('.decision-tools-card__poll-type').forEach(el => {
      if (!el.classList.contains('decision-tools-card__poll-type--meeting')) el.style.display = 'none';
    });
    document.querySelector('.decision-tools-card__poll-type--meeting').scrollIntoView({block: 'center'});
  `)
}

async function fillCommonFields(page, title, details) {
  await page.locator('.poll-common-form-fields__title input').fill(title)
  await page.locator('.poll-common-form-fields__details [contenteditable=true]').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context(title, [
    details,
    'Check the production roster and cafe collection calendar before choosing or proposing an option.',
    'Add a reason if another person needs to account for a delivery, washing, or reporting commitment.'
  ]))
}

async function openTimePollForm(page) {
  await openPollTemplates(page);
  await page.locator('.decision-tools-card__poll-type--meeting').click()
  await fillCommonFields(
    page,
    'Schedule the bottle trial planning meeting',
    'Choose the times you can meet to confirm cafe collections, washing checks, and responsibilities for the six-week trial.'
  );
}

async function openOptInForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_new_poll?poll_type=count')
  await expect(page.locator('.poll-common-form-fields__title input').first()).toBeVisible()
  await fillCommonFields(
    page,
    'Join the reusable packaging working group',
    'We need three people to coordinate bottle deposits, cafe collections, washing checks, and the review of the six-week trial.'
  );
  await page.locator('.poll-common-form__agree-target input').fill('3')
}

async function openMeetingOutcomeForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_meeting_poll?mode=closed')
  await expectLabel(page.locator('.poll-created'), 'Schedule the bottle trial planning meeting')
  await page.locator('.poll-common-set-outcome-panel__submit').click()
  await page.locator('.poll-common-outcome-form__statement [contenteditable=true]').fill('The bottle trial planning meeting will confirm cafe collections, washing checks, and responsibilities.')
  await page.locator('.poll-common-calendar-invite__summary input').fill('Bottle trial planning meeting')
  await page.locator('.poll-common-calendar-invite__location input').fill('Oatmilk Cooperative meeting room')
}

test('meeting_poll_types', async ({ page, manual: screenshot }) => {
  await openPollTemplates(page);
  await screenshot.captureRegion(
    'polls/meeting_polls/meeting_polls',
    ['.poll-common-choose-template__poll', '.decision-tools-card__poll-type--meeting'],
    {padding: 8, width: 1100, height: 900}
  );
});

test('time_poll_label', async ({ page, manual: screenshot }) => {
  await openPollTemplates(page);
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_label',
    '.decision-tools-card__poll-type--meeting',
    {width: 1100, height: 900}
  );
});

test('time_poll_options', async ({ page, manual: screenshot }) => {
  await openTimePollForm(page);
  await page.locator('.poll-meeting-form__option-button').click()
  await page.locator('.poll-common-form input[type="number"]').fill('90')
  await page.evaluate("document.querySelector('.poll-common-form').scrollIntoView({block: 'start'})")
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_options',
    '.poll-common-form',
    {width: 1100, height: 1600}
  );
});

test('opt_in_label', async ({ page, manual: screenshot }) => {
  await openOptInForm(page);
  await screenshot.captureElement(
    'polls/meeting_polls/opt_in_label',
    '.poll-common-form-fields__title',
    {width: 1100, height: 900}
  );
});

test('opt_in_options', async ({ page, manual: screenshot }) => {
  await openOptInForm(page);
  await screenshot.captureElement(
    'polls/meeting_polls/opt_in_options',
    '.poll-common-form',
    {width: 1100, height: 1500}
  );
});

test('time_poll_vote', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_meeting_poll?mode=vote')
  await expectLabel(page.locator('.poll-created'), 'Schedule the bottle trial planning meeting')
  await expect(page.locator('.poll-meeting-vote-form').first()).toBeVisible()
  await screenshot.captureRegion(
    'polls/meeting_polls/timepoll_vote',
    ['.poll-created .poll-common-chart-panel', '.poll-meeting-vote-form'],
    {padding: 12, width: 1200, height: 1500}
  );
});

test('time_poll_outcome', async ({ page, manual: screenshot }) => {
  await openMeetingOutcomeForm(page);
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_outcome',
    '.poll-common-outcome-form',
    {width: 1200, height: 1300}
  );
});

test('time_poll_calendar', async ({ page, manual: screenshot }) => {
  await openMeetingOutcomeForm(page);
  await page.locator('.poll-common-outcome-form__submit').click()
  await expect(page.locator('.poll-common-outcome-panel').first()).toBeVisible()
  await expectLabel(page.locator('.poll-common-outcome-panel'), 'Oatmilk Cooperative meeting room')
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_calendar',
    '.poll-common-outcome-panel',
    {width: 1100, height: 1000}
  );
});

test('opt_in_results', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_opt_in')
  await expectLabel(page.locator('.poll-created'), 'Join the reusable packaging working group')
  await expect(page.locator('.poll-common-chart-panel').first()).toBeVisible()
  await screenshot.captureElement(
    'polls/meeting_polls/opt_in_results',
    '.poll-created .poll-common-chart-panel',
    {width: 1200, height: 1000}
  );
});
