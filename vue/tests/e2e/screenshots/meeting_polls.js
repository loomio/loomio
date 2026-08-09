const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openPollTemplates(page) {
  page.loadPath('setup_manual_oatmilk_formatting?key=0');
  page.expectText('.context-panel__heading', 'Returnable bottles for cafe customers');
  page.clickAndWait('.activity-panel__add-poll', '.poll-common-choose-template__poll');
  page.clickAndWait('.poll-common-choose-template__poll', '.decision-tools-card__poll-type--meeting');
  page.expectText('.decision-tools-card__poll-types', 'Time poll');
  page.execute(`
    document.querySelectorAll('.decision-tools-card__poll-type').forEach(el => {
      if (!el.classList.contains('decision-tools-card__poll-type--meeting')) el.style.display = 'none';
    });
    document.querySelector('.decision-tools-card__poll-type--meeting').scrollIntoView({block: 'center'});
  `);
}

function fillCommonFields(page, title, details) {
  page.waitFor('.poll-common-form-fields__title input');
  page.fillIn('.poll-common-form-fields__title input', title);
  page.fillIn('.poll-common-form-fields__details [contenteditable=true]', details);
}

function openTimePollForm(page) {
  openPollTemplates(page);
  page.clickAndWait('.decision-tools-card__poll-type--meeting', '.poll-common-form-fields__title input');
  fillCommonFields(
    page,
    'Schedule the bottle trial planning meeting',
    'Choose the times you can meet to confirm cafe collections, washing checks, and responsibilities for the six-week trial.'
  );
}

function openOptInForm(page) {
  page.loadPath('setup_manual_oatmilk_new_poll?poll_type=count');
  page.waitFor('.poll-common-form-fields__title input');
  fillCommonFields(
    page,
    'Join the reusable packaging working group',
    'We need three people to coordinate bottle deposits, cafe collections, washing checks, and the review of the six-week trial.'
  );
  page.fillIn('.poll-common-form__agree-target input', '3');
}

function openMeetingOutcomeForm(page) {
  page.loadPath('setup_manual_oatmilk_meeting_poll?mode=closed');
  page.expectText('.poll-created', 'Schedule the bottle trial planning meeting');
  page.clickAndWait('.poll-common-set-outcome-panel__submit', '.poll-common-outcome-form');
  page.fillIn('.poll-common-outcome-form__statement [contenteditable=true]', 'The bottle trial planning meeting will confirm cafe collections, washing checks, and responsibilities.');
  page.clear('.poll-common-calendar-invite__summary input');
  page.fillIn('.poll-common-calendar-invite__summary input', 'Bottle trial planning meeting');
  page.fillIn('.poll-common-calendar-invite__location input', 'Oatmilk Cooperative meeting room');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'meeting_poll_types': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openPollTemplates(page);
    screenshot.captureRegion(
      'polls/meeting_polls/meeting_polls',
      ['.poll-common-choose-template__poll', '.decision-tools-card__poll-type--meeting'],
      {padding: 8, width: 1100, height: 900}
    );
  },

  'time_poll_label': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openPollTemplates(page);
    screenshot.captureElement(
      'polls/meeting_polls/timepoll_label',
      '.decision-tools-card__poll-type--meeting',
      {width: 1100, height: 900}
    );
  },

  'time_poll_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openTimePollForm(page);
    page.click('.poll-meeting-form__option-button');
    page.fillIn('.poll-common-form input[type="number"]', '90');
    page.execute("document.querySelector('.poll-common-form').scrollIntoView({block: 'start'})");
    screenshot.captureElement(
      'polls/meeting_polls/timepoll_options',
      '.poll-common-form',
      {width: 1100, height: 1600}
    );
  },

  'opt_in_label': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openOptInForm(page);
    screenshot.captureElement(
      'polls/meeting_polls/opt_in_label',
      '.poll-common-form-fields__title',
      {width: 1100, height: 900}
    );
  },

  'opt_in_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openOptInForm(page);
    screenshot.captureElement(
      'polls/meeting_polls/opt_in_options',
      '.poll-common-form',
      {width: 1100, height: 1500}
    );
  },

  'time_poll_vote': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_meeting_poll?mode=vote');
    page.expectText('.poll-created', 'Schedule the bottle trial planning meeting');
    page.waitFor('.poll-meeting-vote-form');
    screenshot.captureRegion(
      'polls/meeting_polls/timepoll_vote',
      ['.poll-created .poll-common-chart-panel', '.poll-meeting-vote-form'],
      {padding: 12, width: 1200, height: 1500}
    );
  },

  'time_poll_outcome': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openMeetingOutcomeForm(page);
    screenshot.captureElement(
      'polls/meeting_polls/timepoll_outcome',
      '.poll-common-outcome-form',
      {width: 1200, height: 1300}
    );
  },

  'time_poll_calendar': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openMeetingOutcomeForm(page);
    page.click('.poll-common-outcome-form__submit');
    page.waitFor('.poll-common-outcome-panel');
    page.expectText('.poll-common-outcome-panel', 'Oatmilk Cooperative meeting room');
    screenshot.captureElement(
      'polls/meeting_polls/timepoll_calendar',
      '.poll-common-outcome-panel',
      {width: 1100, height: 1000}
    );
  },

  'opt_in_results': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    page.loadPath('setup_manual_oatmilk_opt_in');
    page.expectText('.poll-created', 'Join the reusable packaging working group');
    page.waitFor('.poll-common-chart-panel');
    screenshot.captureElement(
      'polls/meeting_polls/opt_in_results',
      '.poll-created .poll-common-chart-panel',
      {width: 1200, height: 1000}
    );
  }
};
