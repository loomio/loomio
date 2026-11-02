import { expect } from '@playwright/test';

// Account flows shared by several specs. Each takes a Playwright page.

export async function completeAccount(page, name = 'New Account') {
  await page.fill('.account-completion__name input', name)
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
}

export async function signUpViaInvitation(page, name = 'New person') {
  await page.click('.auth-form__create-account')
  await page.click('.auth-signup-form__submit')
  await completeAccount(page, name)
}

export async function signUpViaEmail(page, email = 'new@account.com') {
  await page.click('.auth-form__create-account')
  await page.fill('.auth-signup-form__email input', email)
  await page.click('.auth-signup-form__submit')
  await expect(page.locator('.auth-complete')).toBeVisible()
  await page.goto('/dev/use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await completeAccount(page)
}

export async function signInViaPassword(page, email, password) {
  if (email) { await page.fill('.auth-email-form__email input', email) }
  await page.fill('.auth-email-form__password input', password)
  await page.click('.auth-email-form__submit')
}

export async function signInViaEmail(page, email) {
  await page.fill('.auth-email-form__email input', email)
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await page.goto('/dev/use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
}
