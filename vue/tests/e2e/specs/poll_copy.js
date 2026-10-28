const pageHelper = require('../helpers/pageHelper');

const tests = {};

for (const [state, scenario] of [
  ['open', 'polls/test_poll_scenario?scenario=poll_created&poll_type=proposal'],
  ['closed', 'polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal'],
  ['scheduled', 'polls/test_scheduled_poll']
]) {
  tests[`can_copy_${state}_proposal_and_start_voting_immediately`] = test => {
    const page = pageHelper(test);
    page.loadPath(scenario);
    // Keep old copy links working even though the poll menu now saves templates.
    page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--save_as_template');
    page.expectNoElement('.action-dock__button--make_a_copy');
    test.getAttribute('.action-dock__button--save_as_template', 'href', result => {
      const pollId = new URL(result.value).searchParams.get('poll_id');
      page.goTo(`p/new?template_id=${pollId}`);
    });
    page.expectElement('.poll-common-form__opens-immediately');

    test.assert.selected('.poll-common-form__opens-immediately input');
    page.expectNoElement('.poll-common-opening-at-field');
    page.click('.poll-common-form__opens-immediately .v-selection-control__wrapper');
    page.expectElement('.poll-common-opening-at-field');
    test.assert.enabled('.poll-common-opening-at-field .v-date-input input');
    test.assert.enabled('.poll-common-opening-at-field__timepicker input');
    page.click('.poll-common-form__opens-immediately .v-selection-control__wrapper');
    page.expectNoElement('.poll-common-opening-at-field');
    page.click('.poll-common-form .v-radio:first-child .v-selection-control__wrapper');

    test.clearValue('.poll-common-form-fields__title input');
    page.fillIn('.poll-common-form-fields__title input', `Copy of ${state} proposal`);
    page.click('.poll-common-form__submit');
    page.expectNoElement('.poll-common-form__submit', 8000);
    page.refreshAndWait();
    page.expectText('.context-panel__heading', `Copy of ${state} proposal`);
    page.expectNoElement('.poll-common-action-panel__scheduled');
    page.expectElement('.poll-common-vote-form__button');
    page.expectNoElement('.poll-common-vote-form--preview');
  };
}

tests.can_open_scheduled_proposal_immediately_by_editing = test => {
  const page = pageHelper(test);
  page.loadPath('polls/test_scheduled_poll');
  page.expectElement('.poll-common-action-panel__scheduled');
  page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
  page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form__opens-immediately');
  page.expectElement('.poll-common-opening-at-field');
  page.click('.poll-common-form__opens-immediately .v-selection-control__wrapper');
  test.assert.selected('.poll-common-form__opens-immediately input');
  page.click('.poll-common-form__submit');
  page.expectNoElement('.poll-common-form__submit', 8000);
  page.refreshAndWait();
  page.expectNoElement('.poll-common-action-panel__scheduled');
  // Opening an invite-only poll must not give uninvited people a vote.
  page.expectElement('.poll-common-unable-to-vote');
  page.expectNoElement('.poll-common-vote-form--preview');
};

module.exports = tests;
