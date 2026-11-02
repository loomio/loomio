import { test, expect } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openPollTemplates(page) {
  await page.loadPath('setup_manual_oatmilk_formatting?key=0');
  await page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  await page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll');
  await page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--meeting');
  await page.expectText('.decision-tools-card__poll-types', 'Time poll');
  await page.execute(`
    document.querySelectorAll('.decision-tools-card__poll-type').forEach(el => {
      if (!el.classList.contains('decision-tools-card__poll-type--meeting')) el.style.display = 'none';
    });
    document.querySelector('.decision-tools-card__poll-type--meeting').scrollIntoView({block: 'center'});
  `);
}

async function fillCommonFields(page, title, details) {
  await page.waitFor('.poll-common-form-fields__title input');
  await page.fillIn('.poll-common-form-fields__title input', title);
  await page.fillRichText('.poll-common-form-fields__details [contenteditable=true]', richText.context(title, [
    details,
    'Check the production roster and cafe collection calendar before choosing or proposing an option.',
    'Add a reason if another person needs to account for a delivery, washing, or reporting commitment.'
  ]));
}

async function openTimePollForm(page) {
  await openPollTemplates(page);
  await page.clickAndWait('.decision-tools-card__poll-type--meeting', '.poll-common-form-fields__title input');
  await fillCommonFields(
    page,
    'Schedule the bottle trial planning meeting',
    'Choose the times you can meet to confirm cafe collections, washing checks, and responsibilities for the six-week trial.'
  );
}

async function openOptInForm(page) {
  await page.loadPath('setup_manual_oatmilk_new_poll?poll_type=count');
  await page.waitFor('.poll-common-form-fields__title input');
  await fillCommonFields(
    page,
    'Join the reusable packaging working group',
    'We need three people to coordinate bottle deposits, cafe collections, washing checks, and the review of the six-week trial.'
  );
  await page.fillIn('.poll-common-form__agree-target input', '3');
}

async function openMeetingOutcomeForm(page) {
  await page.loadPath('setup_manual_oatmilk_meeting_poll?mode=closed');
  await page.expectText('.poll-created', 'Schedule the bottle trial planning meeting');
  await page.clickAndWait('.poll-common-set-outcome-panel__submit', '.poll-common-outcome-form');
  await page.fillIn('.poll-common-outcome-form__statement [contenteditable=true]', 'The bottle trial planning meeting will confirm cafe collections, washing checks, and responsibilities.');
  await page.clear('.poll-common-calendar-invite__summary input');
  await page.fillIn('.poll-common-calendar-invite__summary input', 'Bottle trial planning meeting');
  await page.fillIn('.poll-common-calendar-invite__location input', 'Oatmilk Cooperative meeting room');
}

test('meeting_poll_types', async ({ lmo: page, manual: screenshot }) => {
  await openPollTemplates(page);
  await screenshot.captureRegion(
    'polls/meeting_polls/meeting_polls',
    ['.poll-common-choose-template__poll', '.decision-tools-card__poll-type--meeting'],
    {padding: 8, width: 1100, height: 900}
  );
});

test('time_poll_label', async ({ lmo: page, manual: screenshot }) => {
  await openPollTemplates(page);
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_label',
    '.decision-tools-card__poll-type--meeting',
    {width: 1100, height: 900}
  );
});

test('time_poll_options', async ({ lmo: page, manual: screenshot }) => {
  await openTimePollForm(page);
  await page.click('.poll-meeting-form__option-button');
  await page.fillIn('.poll-common-form input[type="number"]', '90');
  await page.execute("document.querySelector('.poll-common-form').scrollIntoView({block: 'start'})");
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_options',
    '.poll-common-form',
    {width: 1100, height: 1600}
  );
});

test('opt_in_label', async ({ lmo: page, manual: screenshot }) => {
  await openOptInForm(page);
  await screenshot.captureElement(
    'polls/meeting_polls/opt_in_label',
    '.poll-common-form-fields__title',
    {width: 1100, height: 900}
  );
});

test('opt_in_options', async ({ lmo: page, manual: screenshot }) => {
  await openOptInForm(page);
  await screenshot.captureElement(
    'polls/meeting_polls/opt_in_options',
    '.poll-common-form',
    {width: 1100, height: 1500}
  );
});

test('time_poll_vote', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_meeting_poll?mode=vote');
  await page.expectText('.poll-created', 'Schedule the bottle trial planning meeting');
  await page.waitFor('.poll-meeting-vote-form');
  await screenshot.captureRegion(
    'polls/meeting_polls/timepoll_vote',
    ['.poll-created .poll-common-chart-panel', '.poll-meeting-vote-form'],
    {padding: 12, width: 1200, height: 1500}
  );
});

test('time_poll_outcome', async ({ lmo: page, manual: screenshot }) => {
  await openMeetingOutcomeForm(page);
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_outcome',
    '.poll-common-outcome-form',
    {width: 1200, height: 1300}
  );
});

test('time_poll_calendar', async ({ lmo: page, manual: screenshot }) => {
  await openMeetingOutcomeForm(page);
  await page.click('.poll-common-outcome-form__submit');
  await page.waitFor('.poll-common-outcome-panel');
  await page.expectText('.poll-common-outcome-panel', 'Oatmilk Cooperative meeting room');
  await screenshot.captureElement(
    'polls/meeting_polls/timepoll_calendar',
    '.poll-common-outcome-panel',
    {width: 1100, height: 1000}
  );
});

test('opt_in_results', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_opt_in');
  await page.expectText('.poll-created', 'Join the reusable packaging working group');
  await page.waitFor('.poll-common-chart-panel');
  await screenshot.captureElement(
    'polls/meeting_polls/opt_in_results',
    '.poll-created .poll-common-chart-panel',
    {width: 1200, height: 1000}
  );
});
