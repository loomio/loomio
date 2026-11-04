import { expect } from '../fixtures.mjs';
import { openSidebar } from './groups.mjs';

// Sign-in and sign-up steps shared by several specs. Each takes a page showing
// the sign-in form.

const email = page => page.locator('.auth-email-form__email input');

export async function completeAccount(page, name = 'New Account') {
  await page.locator('.account-completion__name input').fill(name);
  await page.locator('.account-completion__legal-accepted input').check();
  await page.locator('.account-completion__submit').click();
}

export async function signInViaPassword(page, address, password) {
  if (address) { await email(page).fill(address); }
  await page.locator('.auth-email-form__password input').fill(password);
  await page.locator('.auth-email-form__submit').click();
}

// Asks for a sign-in code, by default for the address already in the form.
export async function requestLoginCode(page, address) {
  if (address) { await email(page).fill(address); }
  await page.locator('.auth-email-form__login-link').click();
  await page.locator('.auth-email-code-form__submit').click();
  await expect(page.locator('.auth-complete')).toContainText('Check your email');
}

// Types in the code from the last sign-in email.
export async function enterLoginCode(page) {
  const code = await (await page.request.get('/dev/last_login_code')).text();
  await page.locator('.auth-complete__code input').fill(code.trim());
  await page.locator('.auth-complete__submit').click();
}

// Follows the link in the last sign-in email.
export async function useLoginLink(page) {
  await page.goto('/dev/use_last_login_token');
  await page.locator('.auth-signin-form__submit').click();
}

// Creates an account for an address, then waits for the sign-in email.
export async function signUp(page, address) {
  await page.locator('.auth-form__create-account').click();
  if (address) { await page.locator('.auth-signup-form__email input').fill(address); }
  await page.locator('.auth-signup-form__submit').click();
  await expect(page.locator('.auth-complete')).toContainText('Check your email');
}

export async function signUpViaEmail(page, address = 'new@account.com') {
  await signUp(page, address);
  await useLoginLink(page);
  await completeAccount(page);
}

// Accepts an invitation by creating an account for the invited address.
export async function signUpViaInvitation(page, name = 'New person') {
  await page.locator('.auth-form__create-account').click();
  await page.locator('.auth-signup-form__submit').click();
  await completeAccount(page, name);
}

export async function signInViaEmail(page, address) {
  await requestLoginCode(page, address);
  await useLoginLink(page);
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully');
}

export async function signOut(page) {
  await openSidebar(page);
  await page.locator('.sidebar__user-dropdown').click();
  await page.locator('.user-dropdown__list-item-button--sign-out').click();
  await expect(page.locator('.auth-modal')).toBeVisible();
}
