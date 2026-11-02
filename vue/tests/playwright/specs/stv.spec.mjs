import { test, expect } from '../fixtures.mjs';

test('test_stv_vote_form_renders', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_created&poll_type=stv')
  await expect(page.locator('.poll-stv-vote-form')).toBeVisible()
});

test('test_stv_vote_form_needs_a_ranking_to_submit', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_created&poll_type=stv')
  await expect(page.locator('.poll-common-vote-form__submit[disabled]')).toBeVisible()
});
