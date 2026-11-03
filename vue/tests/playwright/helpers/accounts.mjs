import { expect } from '@playwright/test';

// Account flows shared by several specs. Each takes a Playwright page.

export async function completeAccount(page, name = 'New Account') {
  await page.locator('.account-completion__name input').fill(name)
  await page.locator('.account-completion__legal-accepted .v-selection-control__wrapper').click()
  await page.locator('.account-completion__submit').click()
}

export async function signUpViaInvitation(page, name = 'New person') {
  await page.locator('.auth-form__create-account').click()
  await page.locator('.auth-signup-form__submit').click()
  await completeAccount(page, name)
}

export async function signUpViaEmail(page, email = 'new@account.com') {
  await page.locator('.auth-form__create-account').click()
  await page.locator('.auth-signup-form__email input').fill(email)
  await page.locator('.auth-signup-form__submit').click()
  await expect(page.locator('.auth-complete')).toBeVisible()
  await page.goto('/dev/use_last_login_token')
  await page.locator('.auth-signin-form__submit').click()
  await completeAccount(page)
}

export async function signInViaPassword(page, email, password) {
  if (email) { await page.locator('.auth-email-form__email input').fill(email) }
  await page.locator('.auth-email-form__password input').fill(password)
  await page.locator('.auth-email-form__submit').click()
}

export async function signInViaEmail(page, email) {
  await page.locator('.auth-email-form__email input').fill(email)
  await page.locator('.auth-email-form__login-link').click()
  await page.locator('.auth-email-code-form__submit').click()
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await page.goto('/dev/use_last_login_token')
  await page.locator('.auth-signin-form__submit').click()
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
}
