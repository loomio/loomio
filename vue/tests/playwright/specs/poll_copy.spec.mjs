import { test, expect } from '../fixtures.mjs';

for (const [state, scenario] of [
  ['open', 'polls/test_poll_scenario?scenario=poll_created&poll_type=proposal'],
  ['closed', 'polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal'],
  ['scheduled', 'polls/test_scheduled_poll']
]) {
  test(`can_copy_${state}_proposal_and_start_voting_immediately`, async ({ lmo: page }) => {
    await page.loadPath(scenario);
    // Keep old copy links working even though the poll menu now saves templates.
    await page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--save_as_template');
    await page.expectNoElement('.action-dock__button--make_a_copy');
    const templateHref = await page.attribute('.action-dock__button--save_as_template', 'href');
    const pollId = new URL(templateHref, page.page.url()).searchParams.get('poll_id');
    await page.goTo(`p/new?template_id=${pollId}`);
    await page.expectElement('.poll-common-form__opens-immediately');

    await page.expectChecked('.poll-common-form__opens-immediately input');
    await page.expectNoElement('.poll-common-opening-at-field');
    await page.click('.poll-common-form__opens-immediately .v-selection-control__wrapper');
    await page.expectElement('.poll-common-opening-at-field');
    await page.expectEnabled('.poll-common-opening-at-field .v-date-input input');
    await page.expectEnabled('.poll-common-opening-at-field__timepicker input');
    await page.click('.poll-common-form__opens-immediately .v-selection-control__wrapper');
    await page.expectNoElement('.poll-common-opening-at-field');
    await page.click('.poll-common-form .v-radio:first-child .v-selection-control__wrapper');

    await page.clearField('.poll-common-form-fields__title input');
    await page.fillIn('.poll-common-form-fields__title input', `Copy of ${state} proposal`);
    await page.click('.poll-common-form__submit');
    await page.expectNoElement('.poll-common-form__submit', 8000);
    await page.refreshAndWait();
    await page.expectText('.context-panel__heading', `Copy of ${state} proposal`);
    await page.expectNoElement('.poll-common-action-panel__scheduled');
    await page.expectElement('.poll-common-vote-form__button');
    await page.expectNoElement('.poll-common-vote-form--preview');
  });
}

test('can_open_scheduled_proposal_immediately_by_editing', async ({ lmo: page }) => {
  await page.loadPath('polls/test_scheduled_poll');
  await page.expectElement('.poll-common-action-panel__scheduled');
  await page.clickAndWait('.poll-created .action-menu--btn', '.action-dock__button--edit_poll');
  await page.clickAndWait('.action-dock__button--edit_poll', '.poll-common-form__opens-immediately');
  await page.expectElement('.poll-common-opening-at-field');
  await page.click('.poll-common-form__opens-immediately .v-selection-control__wrapper');
  await page.expectChecked('.poll-common-form__opens-immediately input');
  await page.click('.poll-common-form__submit');
  await page.expectNoElement('.poll-common-form__submit', 8000);
  await page.refreshAndWait();
  await page.expectNoElement('.poll-common-action-panel__scheduled');
  // Opening an invite-only poll must not give uninvited people a vote.
  await page.expectElement('.poll-common-unable-to-vote');
  await page.expectNoElement('.poll-common-vote-form--preview');
});

