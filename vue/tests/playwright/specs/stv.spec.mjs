import { test, expect } from '../fixtures.mjs';

test('test_stv_vote_form_renders', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_created&poll_type=stv')
  await page.expectElement('.poll-stv-vote-form')
});

test('test_stv_vote_form_needs_a_ranking_to_submit', async ({ lmo: page }) => {
  await page.loadPath('polls/test_poll_scenario?scenario=poll_created&poll_type=stv')
  await page.expectElement('.poll-common-vote-form__submit[disabled]')
});
