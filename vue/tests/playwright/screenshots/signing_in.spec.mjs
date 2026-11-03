import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function openSignIn(page) {
  await page.goto('/dev/setup_manual_oatmilk_signed_out')
  await page.locator('.navbar__sign-in').click()
}

async function useLightTheme(page) {
  await page.emulateMedia({ colorScheme: 'light' });
}

test('sign_in_email', async ({ page, manual: screenshot }) => {
  await useLightTheme(page);
  await openSignIn(page);
  await page.locator('.auth-email-form__email input').pressSequentially('jamie@oatmilk.example')
  await screenshot.captureElement('users/signing_in/sign_in_email', '.auth-form', {
    width: 1100,
    height: 1200
  });
});

test('sign_in_code', async ({ page, manual: screenshot }) => {
  await useLightTheme(page);
  await openSignIn(page);
  await page.locator('.auth-email-form__email input').pressSequentially('jamie@oatmilk.example')
  await page.locator('.auth-email-form__login-link').click()
  await page.locator('.auth-email-code-form__submit').click()
  await expect(page.locator('.auth-complete').first()).toBeVisible()
  await screenshot.captureElement('users/signing_in/sign_in_code', '.auth-complete', {
    width: 1100,
    height: 1200
  });
});

test('sign_in_token', async ({ page, manual: screenshot }) => {
  await useLightTheme(page);
  await page.goto('/dev/setup_manual_oatmilk_login_token')
  await expect(page.locator('.auth-signin-form__token').first()).toBeVisible()
  await screenshot.captureElement('users/signing_in/sign_in_token', '.auth-signin-form', {
    width: 1100,
    height: 1200
  });
});
