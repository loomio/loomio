import { test, expect } from '../fixtures.mjs';

test('ranked choice vote form needs a ranking before it can be submitted', async ({ page }) => {
  await page.goto('/dev/polls/test_poll_scenario?scenario=poll_created&poll_type=stv')
  await expect(page.locator('.poll-stv-vote-form')).toBeVisible()
  await expect(page.locator('.poll-common-vote-form__submit')).toBeDisabled()
});
