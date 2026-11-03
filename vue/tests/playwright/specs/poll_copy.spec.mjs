import { test, expect } from '../fixtures.mjs';
import { pollAction } from '../helpers/polls.mjs';

const opensImmediately = page => page.locator('.poll-common-form__opens-immediately input');
const openingAt = page => page.locator('.poll-common-opening-at-field');
const scheduledNotice = page => page.locator('.poll-common-action-panel__scheduled');

async function saveAndReload(page) {
  await page.locator('.poll-common-form__submit').click();
  await expect(page.locator('.poll-common-form')).toHaveCount(0);
  await page.reload();
}

for (const [state, scenario] of [
  ['an open', 'polls/test_poll_scenario?scenario=poll_created&poll_type=proposal'],
  ['a closed', 'polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal'],
  ['a scheduled', 'polls/test_scheduled_poll']
]) {
  test(`copies ${state} proposal that opens for voting immediately`, async ({ page }) => {
    await page.goto(`/dev/${scenario}`);
    // The menu now saves templates, but old copy links still work.
    await page.locator('.poll-created .action-menu--btn').click();
    await expect(page.locator('.v-overlay--active .action-dock__button--make_a_copy')).toHaveCount(0);
    const templateHref = await page.locator('.v-overlay--active .action-dock__button--save_as_template').getAttribute('href');
    const pollId = new URL(templateHref, page.url()).searchParams.get('poll_id');
    await page.goto(`/p/new?template_id=${pollId}`);

    await expect(opensImmediately(page)).toBeChecked();
    await expect(openingAt(page)).toHaveCount(0);
    await opensImmediately(page).uncheck();
    await expect(openingAt(page).locator('.v-date-input input')).toBeEnabled();
    await expect(openingAt(page).locator('.poll-common-opening-at-field__timepicker input:not([type=hidden])')).toBeEnabled();
    await opensImmediately(page).check();
    await expect(openingAt(page)).toHaveCount(0);
    await page.locator('.poll-common-settings__all-voters input').check();
    await page.locator('.poll-common-form-fields__title input').fill(`Copy of ${state} proposal`);
    await saveAndReload(page);

    await expect(page.locator('.context-panel__heading')).toContainText(`Copy of ${state} proposal`);
    await expect(scheduledNotice(page)).toHaveCount(0);
    await expect(page.locator('.poll-common-vote-form__button--agree')).toBeVisible();
    await expect(page.locator('.poll-common-vote-form--preview')).toHaveCount(0);
  });
}

test('editing a scheduled proposal to open now', async ({ page }) => {
  await page.goto('/dev/polls/test_scheduled_poll');
  await expect(scheduledNotice(page)).toBeVisible();
  await pollAction(page, 'edit_poll');
  await expect(openingAt(page)).toBeVisible();
  await opensImmediately(page).check();
  await saveAndReload(page);
  await expect(scheduledNotice(page)).toHaveCount(0);
  // Opening an invite-only poll must not give uninvited people a vote.
  await expect(page.locator('.poll-common-unable-to-vote')).toBeVisible();
  await expect(page.locator('.poll-common-vote-form--preview')).toHaveCount(0);
});
