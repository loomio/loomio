import { test, expect } from '../fixtures.mjs';

async function editPoll(page, params = '') {
  await page.loadPath(`polls/test_scheduled_settings${params}`);
  await page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
  await page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form-fields__title input');
  await page.clickAndWait('.poll-common-form__more-settings', '.poll-common-settings__hide-results');
}

test('can_change_scheduled_poll_details_and_show_results_during_voting', async ({ lmo: page }) => {
  await editPoll(page);
  await page.expectNoElement('.poll-common-settings__hide-results.v-input--disabled');
  await page.clearField('.poll-common-form-fields__title input');
  await page.fillIn('.poll-common-form-fields__title input', 'Revised scheduled decision');
  await page.fillTextarea('.poll-common-form-fields__details textarea', 'Revised before voting opens');
  await page.click('.poll-common-settings__hide-results .v-field');
  await page.waitFor('.v-overlay--active .v-list-item');
  await page.clickElement('.v-overlay--active .v-list-item');
  await page.expectText('.poll-common-settings__hide-results', 'Do not hide results');
  await page.click('.poll-common-form__submit');
  await page.expectNoElement('.poll-common-form__submit', 8000);
  await page.refreshAndWait();
  await page.expectText('.context-panel__heading', 'Revised scheduled decision');
  await page.expectText('.poll-common-details-panel__details', 'Revised before voting opens');
  await page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
  await page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form-fields__title input');
  await page.clickAndWait('.poll-common-form__more-settings', '.poll-common-settings__hide-results');
  await page.expectText('.poll-common-settings__hide-results', 'Do not hide results');
});

test('results_hidden_until_closing_stay_locked_after_voting_opens', async ({ lmo: page }) => {
  await editPoll(page, '?opened=1');
  await page.expectElement('.poll-settings-anonymous.v-input--disabled');
  await page.expectElement('.poll-common-settings__hide-results.v-input--disabled');
  await page.expectText('.poll-common-settings__hide-results', 'Until voting is closed');
});

test('scheduled_anonymous_polls_keep_results_hidden', async ({ lmo: page }) => {
  await editPoll(page, '?anonymous=1');
  await page.expectNoElement('.poll-settings-anonymous.v-input--disabled');
  await page.expectElement('.poll-common-settings__hide-results.v-input--disabled');
  await page.expectText('.poll-common-settings__hide-results', 'Until voting is closed');
});

test('can_switch_voting_mode_before_opening_and_keep_the_setting_after_refresh', async ({ lmo: page }) => {
  await editPoll(page);
  await page.expectNoElement('.poll-settings-anonymous.v-input--disabled');
  await page.clickElement('.poll-settings-anonymous input');
  await page.expectChecked('.poll-settings-anonymous input');
  await page.expectElement('.poll-common-settings__hide-results.v-input--disabled');
  await page.click('.poll-common-form__submit');
  await page.expectNoElement('.poll-common-form__submit', 8000);
  await page.refreshAndWait();
  await page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
  await page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form-fields__title input');
  await page.clickAndWait('.poll-common-form__more-settings', '.poll-settings-anonymous');
  await page.expectChecked('.poll-settings-anonymous input');
  await page.expectNoElement('.poll-settings-anonymous.v-input--disabled');

  await page.clickElement('.poll-settings-anonymous input');
  await page.expectNotChecked('.poll-settings-anonymous input');
  await page.click('.poll-common-settings__hide-results .v-field');
  await page.waitFor('.v-overlay--active .v-list-item');
  await page.clickElement('.v-overlay--active .v-list-item');
  await page.click('.poll-common-form__submit');
  await page.expectNoElement('.poll-common-form__submit', 8000);
  await page.refreshAndWait();
  await page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
  await page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form-fields__title input');
  await page.clickAndWait('.poll-common-form__more-settings', '.poll-settings-anonymous');
  await page.expectNotChecked('.poll-settings-anonymous input');
  await page.expectText('.poll-common-settings__hide-results', 'Do not hide results');
});
