const pageHelper = require('../helpers/pageHelper');

module.exports = {
  'records_event_attendance_and_preserves_it_on_reload': browser => {
    const page = pageHelper(browser);
    page.loadPath('polls/event_calendar');
    page.expectText('.poll-event-details', 'Town hall');
    page.expectElement('.poll-event-attendance');
    page.expectText('.poll-event-attendance__no-response', 'No response');
    page.expectCount('.poll-event-attendance__group', 3);
    page.click('.poll-common-vote-form__button:has(input[aria-label="Going"]) .poll-common-vote-form__button-text');
    browser.execute(function() {
      return getComputedStyle(document.querySelector('.poll-common-vote-form__button--agree')).color.replaceAll(' ', '');
    }, [], result => browser.assert.ok(result.value.includes('34,184,102'), 'Going uses the selected option color'));
    page.click('.poll-common-vote-form__submit');
    page.expectNoElement('.poll-common-vote-form', 5000);
    page.expectText('.poll-common-current-vote', 'Going');
    page.expectCount('.poll-event-attendance__group--agree .v-avatar', 1);
    page.refreshAndWait();
    page.expectText('.poll-common-current-vote', 'Going');
  },

  'shows_the_group_calendar_and_provides_a_working_subscription': browser => {
    const page = pageHelper(browser);
    page.loadPath('polls/event_calendar?view=calendar');
    page.expectElement('.group-calendar-panel .v-calendar');
    page.click('.group-calendar-panel .v-select');
    page.waitFor('.v-overlay--active .v-list-item');
    page.clickLastElement('.v-overlay--active .v-list-item');
    page.expectText('.group-calendar-panel', 'Community gathering');
    page.click('.group-calendar-subscribe');
    page.expectElement('.group-calendar-subscription .group-calendar-link input');
    browser.assert.valueContains('.group-calendar-link input', '/calendar/group.ics?token=');
    browser.executeAsync(async function(done) {
      const response = await fetch(document.querySelector('.group-calendar-link input').value);
      done({status: response.status, body: await response.text()});
    }, [], result => {
      browser.assert.equal(result.value.status, 200);
      browser.assert.ok(result.value.body.includes('BEGIN:VCALENDAR'));
      browser.assert.ok(result.value.body.includes('SUMMARY:Community gathering'));
      browser.assert.ok(!result.value.body.includes('ATTENDEE'));
    });
  },

  'creates_an_event_with_schedule_and_attendance_choices': browser => {
    const page = pageHelper(browser);
    page.loadPath('polls/event_calendar?view=form&admin=1');
    page.expectElement('.poll-event-fields');
    page.fillIn('.poll-common-form-fields__title input', 'Planning workshop');
    page.fillIn('.poll-event-location input', 'Workshop room');
    page.click('.poll-common-form__submit');
    page.expectNoElement('.poll-common-form__submit', 10000);
    page.expectText('.context-panel__heading', 'Planning workshop');
    page.expectText('.poll-event-details', 'Workshop room');
    page.expectCount('.poll-common-vote-form__button', 3);
    page.expectText('.poll-common-vote-form', 'Going');
    page.expectText('.poll-common-vote-form', 'Maybe');
    page.expectText('.poll-common-vote-form', 'Not attending');
  },

  'creates_a_linked_event_from_a_time_poll_outcome': browser => {
    const page = pageHelper(browser);
    page.loadPath('polls/event_calendar?source=1');
    page.click('.action-dock__button--create_event');
    page.expectElement('.poll-event-fields');
    browser.assert.valueEquals('.poll-common-form-fields__title input', 'Community gathering');
    browser.assert.valueEquals('.poll-event-location input', 'Town hall');
    page.click('.poll-common-form__submit');
    page.expectNoElement('.poll-common-form__submit', 10000);
    page.expectText('.poll-event-details', 'Town hall');
    page.expectText('.poll-common-vote-form', 'Going');
  }
};
