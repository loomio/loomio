import { test, expect } from '../screenshotFixtures.mjs';

async function openSignIn(page) {
  await page.loadPath('setup_manual_oatmilk_signed_out');
  await page.clickAndWait('.navbar__sign-in', '.auth-form');
}

async function useLightTheme(page) {
  await page.page.emulateMedia({ colorScheme: 'light' });
}

test('sign_in_email', async ({ lmo: page, manual: screenshot }) => {
  await useLightTheme(page);
  await openSignIn(page);
  await page.fillIn('.auth-email-form__email input', 'jamie@oatmilk.example');
  await screenshot.captureElement('users/signing_in/sign_in_email', '.auth-form', {
    width: 1100,
    height: 1200
  });
});

test('sign_in_code', async ({ lmo: page, manual: screenshot }) => {
  await useLightTheme(page);
  await openSignIn(page);
  await page.fillIn('.auth-email-form__email input', 'jamie@oatmilk.example');
  await page.click('.auth-email-form__login-link');
  await page.click('.auth-email-code-form__submit');
  await page.waitFor('.auth-complete');
  await screenshot.captureElement('users/signing_in/sign_in_code', '.auth-complete', {
    width: 1100,
    height: 1200
  });
});

test('sign_in_token', async ({ lmo: page, manual: screenshot }) => {
  await useLightTheme(page);
  await page.loadPath('setup_manual_oatmilk_login_token');
  await page.waitFor('.auth-signin-form__token');
  await screenshot.captureElement('users/signing_in/sign_in_token', '.auth-signin-form', {
    width: 1100,
    height: 1200
  });
});
