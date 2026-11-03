import { test, expect } from '../fixtures.mjs';
import { pollAction } from '../helpers/polls.mjs';
import { choose } from '../helpers/vuetify.mjs';

const anonymous = page => page.locator('.poll-settings-anonymous');
const hideResults = page => page.locator('.poll-common-settings__hide-results');
const disabled = /v-input--disabled/;

async function openSettings(page) {
  await pollAction(page, 'edit_poll');
  await page.locator('.poll-common-form__more-settings').click();
}

// Saves the form and reloads, so later checks see what was saved.
async function saveAndReload(page) {
  await page.locator('.poll-common-form__submit').click();
  await expect(page.locator('.poll-common-form')).toHaveCount(0);
  await page.reload();
}

const scheduled = params => `/dev/polls/test_scheduled_settings${params}`;

test('a scheduled poll\'s details and result visibility can change before voting opens', async ({ page }) => {
  await page.goto(scheduled(''));
  await openSettings(page);
  await expect(hideResults(page)).not.toHaveClass(disabled);
  await page.locator('.poll-common-form-fields__title input').fill('Revised scheduled decision');
  await page.locator('.poll-common-form-fields__details textarea').fill('Revised before voting opens');
  await choose(page, '.poll-common-settings__hide-results', 'Do not hide results');
  await saveAndReload(page);
  await expect(page.locator('.context-panel__heading')).toContainText('Revised scheduled decision');
  await expect(page.locator('.poll-common-details-panel__details')).toContainText('Revised before voting opens');
  await openSettings(page);
  await expect(hideResults(page)).toContainText('Do not hide results');
});

test('results hidden until closing stay locked once voting opens', async ({ page }) => {
  await page.goto(scheduled('?opened=1'));
  await openSettings(page);
  await expect(anonymous(page)).toHaveClass(disabled);
  await expect(hideResults(page)).toHaveClass(disabled);
  await expect(hideResults(page)).toContainText('Until voting is closed');
});

test('a scheduled anonymous poll keeps results hidden', async ({ page }) => {
  await page.goto(scheduled('?anonymous=1'));
  await openSettings(page);
  await expect(anonymous(page)).not.toHaveClass(disabled);
  await expect(hideResults(page)).toHaveClass(disabled);
  await expect(hideResults(page)).toContainText('Until voting is closed');
});

test('anonymous voting can be switched on and off before voting opens', async ({ page }) => {
  const anonymousInput = anonymous(page).locator('input');
  await page.goto(scheduled(''));
  await openSettings(page);
  await expect(anonymous(page)).not.toHaveClass(disabled);
  await anonymousInput.check();
  await expect(hideResults(page)).toHaveClass(disabled);
  await saveAndReload(page);
  await openSettings(page);
  await expect(anonymousInput).toBeChecked();
  await expect(anonymous(page)).not.toHaveClass(disabled);

  await anonymousInput.uncheck();
  await choose(page, '.poll-common-settings__hide-results', 'Do not hide results');
  await saveAndReload(page);
  await openSettings(page);
  await expect(anonymousInput).not.toBeChecked();
  await expect(hideResults(page)).toContainText('Do not hide results');
});
