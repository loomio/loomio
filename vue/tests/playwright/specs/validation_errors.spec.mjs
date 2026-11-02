import { test, expect } from '../fixtures.mjs';

test('discussion_form_shows_validation_errors', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.click('.action-dock__button--edit_thread')
  await page.clearField('.discussion-form__title-input input')
  await page.click('.discussion-form__submit')
  await page.expectFlash('Please check')
  await page.expectFlash('title')
});

test('group_form_shows_validation_errors', async ({ lmo: page }) => {
  await page.loadPath('setup_group')
  await page.click('.action-menu')
  await page.click('.action-dock__button--edit_group')
  await page.clearField('#group-name')
  await page.click('.group-form__submit-button')
  await page.expectFlash('name')
});

test('poll_form_shows_validation_errors', async ({ lmo: page }) => {
  await page.loadPath('polls/test_discussion')
  await page.pause(2000)
  await page.execute("document.querySelector('.activity-panel__add-poll').click()")
  await page.pause(1000)
  await page.execute("document.querySelector('.decision-tools-card__poll-type--proposal').click()")
  await page.waitFor('.poll-common-form-fields__title input')
  await page.clearField('.poll-common-form-fields__title input')
  await page.execute("document.querySelector('.poll-common-form__submit').click()")
  await page.expectFlash('title')
});
