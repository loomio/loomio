import { test, expect } from '../fixtures.mjs';

async function editPoll(page, params = '') {
  await page.goto(`/dev/polls/test_scheduled_settings${params}`)
  await page.click('.poll-created .action-menu--btn')
  await page.click('.action-dock__button--edit_poll')
  await page.click('.poll-common-form__more-settings')
}

test('can_change_scheduled_poll_details_and_show_results_during_voting', async ({ page }) => {
  await editPoll(page);
  await expect(page.locator('.poll-common-settings__hide-results.v-input--disabled')).toHaveCount(0)
  await page.fill('.poll-common-form-fields__title input', 'Revised scheduled decision')
  await page.locator('.poll-common-form-fields__details textarea').evaluate((textarea, value) => {
    Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set.call(textarea, value)
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }, 'Revised before voting opens')
  await page.click('.poll-common-settings__hide-results .v-field')
  await page.click('.v-overlay--active .v-list-item')
  await expect(page.locator('.poll-common-settings__hide-results')).toContainText('Do not hide results')
  await page.click('.poll-common-form__submit')
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()
  await expect(page.locator('.context-panel__heading')).toContainText('Revised scheduled decision')
  await expect(page.locator('.poll-common-details-panel__details')).toContainText('Revised before voting opens')
  await page.click('.poll-created .action-menu--btn')
  await page.click('.action-dock__button--edit_poll')
  await page.click('.poll-common-form__more-settings')
  await expect(page.locator('.poll-common-settings__hide-results')).toContainText('Do not hide results')
});

test('results_hidden_until_closing_stay_locked_after_voting_opens', async ({ page }) => {
  await editPoll(page, '?opened=1');
  await expect(page.locator('.poll-settings-anonymous.v-input--disabled')).toBeVisible()
  await expect(page.locator('.poll-common-settings__hide-results.v-input--disabled')).toBeVisible()
  await expect(page.locator('.poll-common-settings__hide-results')).toContainText('Until voting is closed')
});

test('scheduled_anonymous_polls_keep_results_hidden', async ({ page }) => {
  await editPoll(page, '?anonymous=1');
  await expect(page.locator('.poll-settings-anonymous.v-input--disabled')).toHaveCount(0)
  await expect(page.locator('.poll-common-settings__hide-results.v-input--disabled')).toBeVisible()
  await expect(page.locator('.poll-common-settings__hide-results')).toContainText('Until voting is closed')
});

test('can_switch_voting_mode_before_opening_and_keep_the_setting_after_refresh', async ({ page }) => {
  await editPoll(page);
  await expect(page.locator('.poll-settings-anonymous.v-input--disabled')).toHaveCount(0)
  await page.click('.poll-settings-anonymous input')
  await expect(page.locator('.poll-settings-anonymous input')).toBeChecked()
  await expect(page.locator('.poll-common-settings__hide-results.v-input--disabled')).toBeVisible()
  await page.click('.poll-common-form__submit')
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()
  await page.click('.poll-created .action-menu--btn')
  await page.click('.action-dock__button--edit_poll')
  await page.click('.poll-common-form__more-settings')
  await expect(page.locator('.poll-settings-anonymous input')).toBeChecked()
  await expect(page.locator('.poll-settings-anonymous.v-input--disabled')).toHaveCount(0)

  await page.click('.poll-settings-anonymous input')
  await expect(page.locator('.poll-settings-anonymous input')).not.toBeChecked()
  await page.click('.poll-common-settings__hide-results .v-field')
  await page.click('.v-overlay--active .v-list-item')
  await page.click('.poll-common-form__submit')
  await expect(page.locator('.poll-common-form__submit')).toHaveCount(0)
  await page.reload()
  await page.click('.poll-created .action-menu--btn')
  await page.click('.action-dock__button--edit_poll')
  await page.click('.poll-common-form__more-settings')
  await expect(page.locator('.poll-settings-anonymous input')).not.toBeChecked()
  await expect(page.locator('.poll-common-settings__hide-results')).toContainText('Do not hide results')
});
