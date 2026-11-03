import { test, expect } from '../fixtures.mjs';

for (const [state, scenario] of [
  ['open', 'polls/test_poll_scenario?scenario=poll_created&poll_type=proposal'],
  ['closed', 'polls/test_poll_scenario?scenario=poll_closed&poll_type=proposal'],
  ['scheduled', 'polls/test_scheduled_poll']
]) {
  test(`can_copy_${state}_proposal_and_start_voting_immediately`, async ({ page }) => {
    await page.goto(`/dev/${scenario}`)
    // Keep old copy links working even though the poll menu now saves templates.
    await page.locator('.poll-created .action-menu--btn').click()
    await expect(page.locator('.action-dock__button--make_a_copy')).toHaveCount(0)
    const templateHref = await page.locator('.action-dock__button--save_as_template').first().getAttribute('href');
    const pollId = new URL(templateHref, page.url()).searchParams.get('poll_id');
    await page.goto(`/p/new?template_id=${pollId}`)
    await expect(page.locator('.poll-common-form__opens-immediately')).toBeVisible()

    await expect(page.locator('.poll-common-form__opens-immediately input')).toBeChecked()
    await expect(page.locator('.poll-common-opening-at-field')).toHaveCount(0)
    await page.locator('.poll-common-form__opens-immediately .v-selection-control__wrapper').click()
    await expect(page.locator('.poll-common-opening-at-field')).toBeVisible()
    await expect(page.locator('.poll-common-opening-at-field .v-date-input input')).toBeEnabled()
    await expect(page.locator('.poll-common-opening-at-field__timepicker input:not([type=hidden])')).toBeEnabled()
    await page.locator('.poll-common-form__opens-immediately .v-selection-control__wrapper').click()
    await expect(page.locator('.poll-common-opening-at-field')).toHaveCount(0)
    await page.locator('.poll-common-form .v-radio:first-child .v-selection-control__wrapper').click()

    await page.locator('.poll-common-form-fields__title input').fill(`Copy of ${state} proposal`)
    await page.locator('.poll-common-form__submit').click()
    await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
    await page.reload()
    await expect(page.locator('.context-panel__heading')).toContainText(`Copy of ${state} proposal`)
    await expect(page.locator('.poll-common-action-panel__scheduled')).toHaveCount(0)
    await expect(page.locator('.poll-common-vote-form__button').first()).toBeVisible()
    await expect(page.locator('.poll-common-vote-form--preview')).toHaveCount(0)
  });
}

test('can_open_scheduled_proposal_immediately_by_editing', async ({ page }) => {
  await page.goto('/dev/polls/test_scheduled_poll')
  await expect(page.locator('.poll-common-action-panel__scheduled')).toBeVisible()
  await page.locator('.poll-created .action-menu--btn').click()
  await page.locator('.action-dock__button--edit_poll').click()
  await expect(page.locator('.poll-common-opening-at-field')).toBeVisible()
  await page.locator('.poll-common-form__opens-immediately .v-selection-control__wrapper').click()
  await expect(page.locator('.poll-common-form__opens-immediately input')).toBeChecked()
  await page.locator('.poll-common-form__submit').click()
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()
  await expect(page.locator('.poll-common-action-panel__scheduled')).toHaveCount(0)
  // Opening an invite-only poll must not give uninvited people a vote.
  await expect(page.locator('.poll-common-unable-to-vote')).toBeVisible()
  await expect(page.locator('.poll-common-vote-form--preview')).toHaveCount(0)
});

