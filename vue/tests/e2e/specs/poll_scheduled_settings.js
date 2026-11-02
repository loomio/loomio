const pageHelper = require('../helpers/pageHelper');

function editPoll(test, params = '') {
  const page = pageHelper(test);
  page.loadPath(`polls/test_scheduled_settings${params}`);
  page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
  page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form-fields__title input');
  page.clickAndWait('.poll-common-form__more-settings', '.poll-common-settings__hide-results');
  return page;
}

module.exports = {
  can_change_scheduled_poll_details_and_show_results_during_voting: test => {
    const page = editPoll(test);
    page.expectNoElement('.poll-common-settings__hide-results.v-input--disabled');
    test.clearValue('.poll-common-form-fields__title input');
    page.fillIn('.poll-common-form-fields__title input', 'Revised scheduled decision');
    page.fillTextarea('.poll-common-form-fields__details textarea', 'Revised before voting opens');
    test.click('.poll-common-settings__hide-results .v-field');
    page.waitFor('.v-overlay--active .v-list-item');
    page.clickElement('.v-overlay--active .v-list-item');
    page.expectText('.poll-common-settings__hide-results', 'Do not hide results');
    page.click('.poll-common-form__submit');
    page.expectNoElement('.poll-common-form__submit', 8000);
    page.refreshAndWait();
    page.expectText('.context-panel__heading', 'Revised scheduled decision');
    page.expectText('.poll-common-details-panel__details', 'Revised before voting opens');
    page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
    page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form-fields__title input');
    page.clickAndWait('.poll-common-form__more-settings', '.poll-common-settings__hide-results');
    page.expectText('.poll-common-settings__hide-results', 'Do not hide results');
  },

  results_hidden_until_closing_stay_locked_after_voting_opens: test => {
    const page = editPoll(test, '?opened=1');
    page.expectElement('.poll-settings-anonymous.v-input--disabled');
    page.expectElement('.poll-common-settings__hide-results.v-input--disabled');
    page.expectText('.poll-common-settings__hide-results', 'Until voting is closed');
  },

  scheduled_anonymous_polls_keep_results_hidden: test => {
    const page = editPoll(test, '?anonymous=1');
    page.expectNoElement('.poll-settings-anonymous.v-input--disabled');
    page.expectElement('.poll-common-settings__hide-results.v-input--disabled');
    page.expectText('.poll-common-settings__hide-results', 'Until voting is closed');
  },

  can_switch_voting_mode_before_opening_and_keep_the_setting_after_refresh: test => {
    const page = editPoll(test);
    page.expectNoElement('.poll-settings-anonymous.v-input--disabled');
    page.clickElement('.poll-settings-anonymous input');
    test.assert.selected('.poll-settings-anonymous input');
    page.expectElement('.poll-common-settings__hide-results.v-input--disabled');
    page.click('.poll-common-form__submit');
    page.expectNoElement('.poll-common-form__submit', 8000);
    page.refreshAndWait();
    page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
    page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form-fields__title input');
    page.clickAndWait('.poll-common-form__more-settings', '.poll-settings-anonymous');
    test.assert.selected('.poll-settings-anonymous input');
    page.expectNoElement('.poll-settings-anonymous.v-input--disabled');

    page.clickElement('.poll-settings-anonymous input');
    test.assert.not.selected('.poll-settings-anonymous input');
    test.click('.poll-common-settings__hide-results .v-field');
    page.waitFor('.v-overlay--active .v-list-item');
    page.clickElement('.v-overlay--active .v-list-item');
    page.click('.poll-common-form__submit');
    page.expectNoElement('.poll-common-form__submit', 8000);
    page.refreshAndWait();
    page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
    page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form-fields__title input');
    page.clickAndWait('.poll-common-form__more-settings', '.poll-settings-anonymous');
    test.assert.not.selected('.poll-settings-anonymous input');
    page.expectText('.poll-common-settings__hide-results', 'Do not hide results');
  }
};
