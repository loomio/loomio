import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import richText from '../helpers/oatmilkRichText.mjs';

const meetingTemplate = '.decision-tools-card__poll-type--meeting';

async function openPollTemplates(page) {
  await page.goto('/dev/setup_manual_oatmilk_formatting?key=0');
  await expectLabel(page.locator('.context-panel__heading'), 'Returnable bottles for cafe customers');
  await page.locator('.activity-panel__add-poll').click();
  await page.locator('.poll-common-choose-template__poll').click();
  await expectLabel(page.locator('.decision-tools-card__poll-types'), 'Time poll');
  // Show only the time poll template.
  await page.locator(`.decision-tools-card__poll-type:not(${meetingTemplate})`)
    .evaluateAll(templates => templates.forEach(template => { template.style.display = 'none'; }));
  await page.locator(meetingTemplate).evaluate(template => template.scrollIntoView({ block: 'center' }));
}

async function fillCommonFields(page, title, details) {
  await page.locator('.poll-common-form-fields__title input').fill(title);
  // Rich content is set directly; typing it would be slow and lose formatting.
  await editor(page.locator('.poll-common-form-fields__details')).evaluate((element, html) => {
    element.focus();
    element.innerHTML = html;
    element.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }));
  }, richText.context(title, [
    details,
    'Check the production roster and cafe collection calendar before choosing or proposing an option.',
    'Add a reason if another person needs to account for a delivery, washing, or reporting commitment.'
  ]));
}

async function openTimePollForm(page) {
  await openPollTemplates(page);
  await page.locator(meetingTemplate).click();
  await fillCommonFields(
    page,
    'Schedule the bottle trial planning meeting',
    'Choose the times you can meet to confirm cafe collections, washing checks, and responsibilities for the six-week trial.'
  );
}

async function openOptInForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_new_poll?poll_type=count');
  await fillCommonFields(
    page,
    'Join the reusable packaging working group',
    'We need three people to coordinate bottle deposits, cafe collections, washing checks, and the review of the six-week trial.'
  );
  await page.locator('.poll-common-form__agree-target input').fill('3');
}

async function openMeetingOutcomeForm(page) {
  await page.goto('/dev/setup_manual_oatmilk_meeting_poll?mode=closed');
  await expectLabel(page.locator('.poll-created'), 'Schedule the bottle trial planning meeting');
  await page.locator('.poll-common-set-outcome-panel__submit').click();
  const form = page.locator('.poll-common-outcome-form');
  await editor(form.locator('.poll-common-outcome-form__statement')).fill('The bottle trial planning meeting will confirm cafe collections, washing checks, and responsibilities.');
  await form.locator('.poll-common-calendar-invite__summary input').fill('Bottle trial planning meeting');
  await form.locator('.poll-common-calendar-invite__location input').fill('Oatmilk Cooperative meeting room');
}

test('meeting_poll_types', async ({ page, manual: screenshot }) => {
  await openPollTemplates(page);
  await screenshot.captureRegion(
    'polls/meeting_polls/meeting_polls',
    ['.poll-common-choose-template__poll', meetingTemplate],
    { padding: 8, width: 1100, height: 900 }
  );
});

test('time_poll_label', async ({ page, manual: screenshot }) => {
  await openPollTemplates(page);
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_label',
    meetingTemplate,
    { width: 1100, height: 900 }
  );
});

test('time_poll_options', async ({ page, manual: screenshot }) => {
  await openTimePollForm(page);
  await page.locator('.poll-meeting-form__option-button').click();
  await page.locator('.poll-meeting-form__duration input').fill('90');
  await page.locator('.poll-common-form').evaluate(form => form.scrollIntoView({ block: 'start' }));
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_options',
    '.poll-common-form',
    { width: 1100, height: 1600 }
  );
});

test('opt_in_label', async ({ page, manual: screenshot }) => {
  await openOptInForm(page);
  await screenshot.captureElement(
    'polls/meeting_polls/opt_in_label',
    '.poll-common-form-fields__title',
    { width: 1100, height: 900 }
  );
});

test('opt_in_options', async ({ page, manual: screenshot }) => {
  await openOptInForm(page);
  await screenshot.captureElement(
    'polls/meeting_polls/opt_in_options',
    '.poll-common-form',
    { width: 1100, height: 1500 }
  );
});

test('time_poll_vote', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_meeting_poll?mode=vote');
  await expectLabel(page.locator('.poll-created'), 'Schedule the bottle trial planning meeting');
  await expect(page.locator('.poll-meeting-vote-form')).toBeVisible();
  await screenshot.captureRegion(
    'polls/meeting_polls/timepoll_vote',
    ['.poll-created .poll-common-chart-panel', '.poll-meeting-vote-form'],
    { padding: 12, width: 1200, height: 1500 }
  );
});

test('time_poll_outcome', async ({ page, manual: screenshot }) => {
  await openMeetingOutcomeForm(page);
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_outcome',
    '.poll-common-outcome-form',
    { width: 1200, height: 1300 }
  );
});

test('time_poll_calendar', async ({ page, manual: screenshot }) => {
  await openMeetingOutcomeForm(page);
  await page.locator('.poll-common-outcome-form__submit').click();
  await expectLabel(page.locator('.poll-common-outcome-panel'), 'Oatmilk Cooperative meeting room');
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_calendar',
    '.poll-common-outcome-panel',
    { width: 1100, height: 1000 }
  );
});

test('opt_in_results', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_opt_in');
  await expectLabel(page.locator('.poll-created'), 'Join the reusable packaging working group');
  await expect(page.locator('.poll-created .poll-common-chart-panel')).toBeVisible();
  await screenshot.captureElement(
    'polls/meeting_polls/opt_in_results',
    '.poll-created .poll-common-chart-panel',
    { width: 1200, height: 1000 }
  );
});
