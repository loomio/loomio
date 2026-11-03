import { test, expect } from '../fixtures.mjs';
import {
  completeAccount, enterLoginCode, requestLoginCode, signInViaEmail, signInViaPassword, signOut, signUp,
  signUpViaInvitation, useLoginLink
} from '../helpers/accounts.mjs';
import { addPasskeyAuthenticator, withoutPasskeys } from '../helpers/passkeys.mjs';

const authComplete = page => page.locator('.auth-complete');
const emailInput = page => page.locator('.auth-email-form__email input');
const credentialPrompt = page => page.locator('.credential-prompt');
const offersPasskey = page => page.locator('.credential-prompt__passkey');
const offersPassword = page => page.locator('.credential-prompt__password');
const passkeySettings = page => page.locator('.passkey-settings');
const accountCompletion = page => page.locator('.account-completion');
const groupName = page => page.locator('.group-page__name');
const validationError = page => page.locator('.lmo-validation-error__message');

const passwordUser = 'password-user@example.com';
const easyPassword = 'veryeasytoguess123';

test.describe('passkeys', () => {
  test.beforeEach(async ({ page }) => {
    await addPasskeyAuthenticator(page);
  });

  test('registers a passkey, signs in with it, and removes it', async ({ page, flash }) => {
    await page.goto('/dev/setup_discussion');
    await page.goto('/profile');
    const name = passkeySettings(page).locator('.passkey-settings__name input');
    await expect(name).toHaveValue(/passkey/i);
    await name.fill('Test passkey');
    await page.locator('.passkey-settings__add').click();
    await expect(flash).toContainText('Passkey added');
    await expect(passkeySettings(page)).toContainText('Test passkey');

    await signOut(page);
    await page.locator('.auth-passkey-button__submit').click();
    await expect(flash).toContainText('Signed in successfully');
    await expect(page.locator('.dashboard-page')).toBeVisible();

    await page.goto('/profile');
    await expect(passkeySettings(page)).toContainText('Test passkey');
    await page.locator('.passkey-settings__remove').click();
    await expect(flash).toContainText('Passkey removed');
    await expect(passkeySettings(page)).toContainText('You have not added a passkey');
  });

  test('a user signed in with a code adds a passkey from the prompt', async ({ page, flash }) => {
    await page.goto('/dev/setup_login_token_user_with_password');
    await requestLoginCode(page, passwordUser);
    await expect(authComplete(page)).toContainText(`If an account exists for ${passwordUser}, we'll send a sign-in code`);
    await enterLoginCode(page);
    await expect(credentialPrompt(page)).toContainText('A passkey lets you sign in quickly');
    await expect(offersPassword(page)).toBeVisible();
    await offersPasskey(page).click();
    await expect(flash).toContainText('Passkey added');
    await expect(credentialPrompt(page)).toHaveCount(0);
    await page.goto('/profile');
    await expect(passkeySettings(page)).toContainText('Passkey');
  });

  test('a user signed in with a password adds a passkey from the prompt', async ({ page, flash }) => {
    await page.goto('/dev/setup_login_token_user_with_password');
    await signInViaPassword(page, passwordUser, easyPassword);
    await expect(credentialPrompt(page)).toContainText('Passkeys');
    await expect(offersPassword(page)).toHaveCount(0);
    await offersPasskey(page).click();
    await expect(flash).toContainText('Passkey added');
    await expect(credentialPrompt(page)).toHaveCount(0);
    await page.goto('/profile');
    await expect(passkeySettings(page)).toContainText('Passkey');
  });

  test('a dismissed passkey offer is not shown again', async ({ page, flash }) => {
    await page.goto('/dev/setup_login_token_user_with_password');
    await signInViaPassword(page, passwordUser, easyPassword);
    await expect(offersPasskey(page)).toBeVisible();
    await credentialPrompt(page).locator('.dismiss-modal-button').click();
    await expect(credentialPrompt(page)).toHaveCount(0);

    await page.goto('/profile');
    await expect(passkeySettings(page)).toBeVisible();
    await signOut(page);
    await signInViaPassword(page, passwordUser, easyPassword);
    await expect(flash).toContainText('Signed in successfully');
    await expect(credentialPrompt(page)).toHaveCount(0);
  });

  test('a code sign-in to an account with a passkey offers a password and a passkey', async ({ page }) => {
    await page.goto('/dev/setup_login_token_user_with_passkey');
    await requestLoginCode(page, 'passkey-user@example.com');
    await enterLoginCode(page);
    await expect(credentialPrompt(page)).toContainText('A passkey lets you sign in quickly');
    await expect(offersPassword(page)).toBeVisible();
    await expect(offersPasskey(page)).toBeVisible();
  });
});

test.describe('without passkey support, a code sign-in offers a password', () => {
  test.beforeEach(async ({ page }) => {
    await withoutPasskeys(page);
  });

  test('to set one', async ({ page }) => {
    await page.goto('/dev/setup_login_token_user_without_password');
    await requestLoginCode(page, 'no-password@example.com');
    await enterLoginCode(page);
    await expect(credentialPrompt(page)).toContainText('Set a password?');
    await expect(offersPasskey(page)).toHaveCount(0);
    await offersPassword(page).click();
    await expect(page.locator('.change-password-form')).toContainText('Set your password');
  });

  test('to reset an existing one', async ({ page }) => {
    await page.goto('/dev/setup_login_token_user_with_password');
    await requestLoginCode(page, passwordUser);
    await enterLoginCode(page);
    await expect(credentialPrompt(page)).toContainText('Would you like to set a new password?');
    await expect(offersPasskey(page)).toHaveCount(0);
    await offersPassword(page).click();
    await expect(page.locator('.change-password-form')).toContainText('Set your password');
  });

  test('which stays dismissed after a reload', async ({ page }) => {
    await page.goto('/dev/setup_login_token_user_without_password');
    await requestLoginCode(page, 'no-password@example.com');
    await enterLoginCode(page);
    await expect(credentialPrompt(page)).toContainText('Set a password?');
    await page.locator('.credential-prompt__dismiss').click();
    await expect(credentialPrompt(page)).toHaveCount(0);
    await page.reload();
    await expect(page.locator('.dashboard-page')).toBeVisible();
    await expect(credentialPrompt(page)).toHaveCount(0);
  });
});

test.describe('completing an account', () => {
  test('a returning user without a recorded legal acceptance signs straight in', async ({ page }) => {
    await page.goto('/dev/setup_returning_user_without_legal_acceptance');
    await signInViaPassword(page, 'returning-no-terms@example.com', easyPassword);
    await expect(page.locator('.dashboard-page')).toBeVisible();
    await expect(accountCompletion(page)).toHaveCount(0);
    await page.reload();
    await expect(page.locator('.dashboard-page')).toBeVisible();
    await expect(accountCompletion(page)).toHaveCount(0);
  });

  for (const [description, name] of [['no name', null], ['an empty name', ''], ['a blank name', '   ']]) {
    test(`a legacy session with ${description} is asked for a name`, async ({ page }) => {
      const query = name === null ? '' : `?name=${encodeURIComponent(name)}`;
      await page.goto(`/dev/setup_legacy_session_without_name${query}`);
      await expect(accountCompletion(page)).toBeVisible();
      await expect(page.locator('.auth-modal')).toHaveCount(0);
      await expect(page.locator('.account-completion__legal-accepted')).toHaveCount(0);
      await expect(page.locator('.account-completion__submit')).toBeDisabled();
      await page.reload();
      await page.locator('.account-completion__name input').fill('Returning Person');
      await page.locator('.account-completion__submit').click();
      await expect(accountCompletion(page)).toHaveCount(0);
      await page.reload();
      await expect(page.locator('.dashboard-page')).toBeVisible();
      await expect(accountCompletion(page)).toHaveCount(0);
      await page.goto('/profile');
      await expect(page.locator('.profile-page__name-input input')).toHaveValue('Returning Person');
    });
  }
});

test.describe('signing up', () => {
  test('from the dashboard', async ({ page, flash }) => {
    await page.goto('/dev/setup_dashboard_as_visitor');
    await signUp(page, 'max_von_sydow@example.com');
    await expect(authComplete(page)).toContainText("We've sent an email to max_von_sydow@example.com");
    await expect(page.locator('.auth-complete__submit')).toContainText('Continue');
    await useLoginLink(page);
    await completeAccount(page, 'Max Von Sydow');
    await expect(flash).toContainText('Signed in successfully');
    await expect(credentialPrompt(page)).toHaveCount(0);
  });

  test('with a code offers ways to sign in next time', async ({ page }) => {
    await page.goto('/dev/setup_dashboard_as_visitor');
    await signUp(page, 'new-code-user@example.com');
    await enterLoginCode(page);
    await completeAccount(page, 'New Code User');
    await expect(offersPassword(page)).toBeVisible();
  });

  test('with an existing address sends a sign-in code', async ({ page }) => {
    await page.goto('/dev/setup_login_token_user_with_password');
    await signUp(page, passwordUser);
    await expect(authComplete(page)).toContainText(`We've sent an email to ${passwordUser}`);
    await expect(page.locator('.auth-complete__submit')).toContainText('Continue');
  });

  test('from a thread', async ({ page, flash }) => {
    await page.goto('/dev/view_open_discussion_as_visitor');
    await page.locator('.add-comment-panel__sign-in-btn').click();
    await signUp(page, 'max_von_sydow@example.com');
    await useLoginLink(page);
    await completeAccount(page, 'Max Von Sydow');
    await expect(flash).toContainText('Signed in successfully');
  });

  test('from a shareable group link', async ({ page, flash }) => {
    await page.goto('/dev/view_closed_group_with_shareable_link');
    await signUp(page, 'max_von_sydow@example.com');
    await useLoginLink(page);
    await completeAccount(page, 'Max Von Sydow');
    await expect(flash).toContainText('Signed in successfully');
    await expect(credentialPrompt(page)).toHaveCount(0);
  });

  test('from the trial page, then completing the account', async ({ page, flash }) => {
    const address = `trial-person-${Date.now()}@example.com`;
    await page.goto('/dev/setup_dashboard_as_visitor');
    await page.goto('/try');
    const form = page.locator('.start-trial-form');
    await form.locator('.start-trial-form__name input').fill('Trial Person');
    await form.locator('.start-trial-form__email input').fill(address);
    await form.locator('.start-trial-form__group-name input').fill('Trial Group');
    await form.locator('.start-trial-form__submit').click();
    await expect(page.locator('.trial-started')).toContainText(`We have created a user account for ${address}`);
    await page.locator('.trial-started__sign-in').click();
    await expect(emailInput(page)).toHaveValue(address);
    await requestLoginCode(page);
    await enterLoginCode(page);
    await expect(page.locator('.account-completion__name input')).toHaveValue('Trial Person');
    await page.locator('.account-completion__legal-accepted input').check();
    await page.locator('.account-completion__submit').click();
    await expect(flash).toContainText('Signed in successfully');
    await page.goto('/profile');
    await expect(page.locator('.profile-page__name-input input')).toHaveValue('Trial Person');
    await expect(page.locator('.profile-page__email-input input')).toHaveValue(address);
  });
});

test.describe('the sign-in form', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_dashboard_as_visitor');
  });

  test('asks for an address when requesting a code without one', async ({ page }) => {
    await page.locator('.auth-email-form__login-link').click();
    const codeForm = page.locator('.auth-email-code-form');
    await expect(codeForm).toContainText('We’ll send a six-digit code to your email address');
    await codeForm.locator('.auth-email-code-form__email input').fill('patrick@example.com');
    await codeForm.locator('.auth-email-code-form__submit').click();
    await expect(authComplete(page)).toContainText('Check your email');
  });

  test('fills the new account form with the address typed', async ({ page }) => {
    await emailInput(page).fill('new-person@example.com');
    await page.locator('.auth-form__create-account').click();
    await expect(page.locator('.auth-signup-form__email input')).toHaveValue('new-person@example.com');
  });

  test('does not carry an invalid address into other forms', async ({ page }) => {
    await emailInput(page).fill('not-an-email');
    await page.locator('.auth-form__create-account').click();
    await expect(page.locator('.auth-signup-form__email input')).toHaveValue('');
    await page.locator('.auth-back-button').click();
    await emailInput(page).fill('still-not-an-email');
    await page.locator('.auth-email-form__login-link').click();
    await expect(page.locator('.auth-email-code-form__email input')).toHaveValue('');
  });

  test('goes back to correct the address for a code', async ({ page }) => {
    await requestLoginCode(page, 'wrong@example.com');
    await page.locator('.auth-back-button').click();
    await expect(emailInput(page)).toHaveValue('wrong@example.com');
  });

  test('sends a code to a user with a password', async ({ page, flash }) => {
    await requestLoginCode(page, 'patrick@example.com');
    await useLoginLink(page);
    await expect(flash).toContainText('Signed in successfully');
  });

  test('signs in by email from the dashboard', async ({ page }) => {
    await signInViaEmail(page, 'jennifer@example.com');
    await expect(page.locator('.dashboard-page')).toBeVisible();
  });
});

test.describe('signing in', () => {
  test('with a sign-in link', async ({ page, flash }) => {
    await page.goto('/dev/setup_login_token');
    await expect(page.locator('.auth-signin-form__token .lmo-pointer')).toHaveCount(0);
    await page.locator('.auth-signin-form__submit').click();
    await expect(flash).toContainText('Signed in successfully');
  });

  test('fails with a used sign-in link', async ({ page }) => {
    await page.goto('/dev/setup_used_login_token');
    await page.locator('.auth-signin-form__submit').click();
    await expect(validationError(page)).toContainText('Click below to send another one');
  });

  test('fails with the wrong password', async ({ page }) => {
    await page.goto('/dev/setup_explore_as_visitor');
    await page.locator('.navbar__sign-in').click();
    await signInViaPassword(page, 'patrick@example.com', 'w0rstmovie');
    await expect(validationError(page)).toContainText('Unable to sign you in with those details');
  });

  test('from a thread', async ({ page, flash }) => {
    await page.goto('/dev/view_open_discussion_as_visitor');
    await page.locator('.add-comment-panel__sign-in-btn').click();
    await signInViaPassword(page, 'patrick@example.com', 'gh0stmovie');
    await expect(flash).toContainText('Signed in successfully');
  });

  test('from the explore page with a password', async ({ page, flash }) => {
    await page.goto('/dev/setup_explore_as_visitor');
    await page.locator('.navbar__sign-in').click();
    await signInViaPassword(page, 'patrick@example.com', 'gh0stmovie');
    await expect(flash).toContainText('Signed in successfully');
  });

  test('from the explore page with a code', async ({ page }) => {
    await page.goto('/dev/setup_explore_as_visitor');
    await page.locator('.navbar__sign-in').click();
    await signInViaEmail(page, 'jennifer@example.com');
  });

  test('from a closed group page', async ({ page, flash }) => {
    await page.goto('/dev/view_closed_group_as_visitor');
    await page.locator('.navbar__sign-in').click();
    await signInViaPassword(page, 'patrick@example.com', 'gh0stmovie');
    await expect(flash).toContainText('Signed in successfully');
    await expect(groupName(page)).toContainText('Closed Dirty Dancing Shoes');
    await expect(page.locator('.topic-previews')).toContainText('This thread is private');
  });

  test('from a secret group page', async ({ page, flash }) => {
    await page.goto('/dev/view_secret_group_as_visitor');
    await signInViaPassword(page, 'patrick@example.com', 'gh0stmovie');
    await expect(flash).toContainText('Signed in successfully');
    await expect(groupName(page)).toContainText('Secret Dirty Dancing Shoes');
  });
});

test.describe('accepting a group invitation', () => {
  const acceptInvitation = async (page, scenario) => {
    await page.goto(`/dev/${scenario}`);
    await expect(page.locator('.email-body')).toContainText('Accept invitation');
    await page.locator('.email-button').click();
  };

  test('an existing user signs in with a code', async ({ page, flash }) => {
    await acceptInvitation(page, 'setup_invitation_email_to_user_with_password');
    await requestLoginCode(page);
    await useLoginLink(page);
    await expect(flash).toContainText('Signed in successfully');
    await expect(groupName(page)).toContainText('Dirty Dancing Shoes');
    await expect(page.locator('.join-group-button')).toHaveCount(0);
  });

  test('a new user signs up', async ({ page, flash }) => {
    await acceptInvitation(page, 'setup_invitation_email_to_visitor');
    await signUpViaInvitation(page, 'Billy Jeans');
    await expect(flash).toContainText('Signed in successfully');
    await expect(groupName(page)).toContainText('Dirty Dancing Shoes');
  });

  test('a new user who changes the address must verify it', async ({ page, flash }) => {
    await acceptInvitation(page, 'setup_invitation_email_to_visitor');
    await page.locator('.auth-form__create-account').click();
    await page.locator('.auth-signup-form__email input').fill('max_von_sydow@merciless.com');
    await expect(page.locator('.auth-signup-form')).toContainText('New to');
    await page.locator('.auth-signup-form__submit').click();
    await expect(authComplete(page)).toContainText('Check your email');
    await useLoginLink(page);
    await completeAccount(page, 'Billy Jeans');
    await expect(flash).toContainText('Signed in successfully');
  });

  test('an existing user signs in with another address', async ({ page, flash }) => {
    await acceptInvitation(page, 'setup_invite_user_with_alternative_email');
    await expect(page.locator('.auth-form')).toContainText('If you are already a Loomio user, sign in with your existing account');
    await signInViaPassword(page, 'existing-user@example.com', easyPassword);
    await expect(flash).toContainText('Signed in successfully');
    await expect(groupName(page)).toContainText('Dirty Dancing Shoes');
  });

  test('an existing user signed in with another address joins at once', async ({ page }) => {
    await acceptInvitation(page, 'setup_invite_user_with_alternative_email?signed_in=1');
    await expect(groupName(page)).toContainText('Dirty Dancing Shoes');
    await expect(page.locator('.auth-modal')).toHaveCount(0);
  });

  test('an existing user signs in with the invited address', async ({ page, flash }) => {
    await acceptInvitation(page, 'setup_invite_user_with_correct_email');
    await signInViaPassword(page, null, easyPassword);
    await expect(flash).toContainText('Signed in successfully');
    await expect(groupName(page)).toContainText('Dirty Dancing Shoes');
  });

  test('an existing user signed in with the invited address joins at once', async ({ page }) => {
    await acceptInvitation(page, 'setup_invite_user_with_correct_email?signed_in=1');
    await expect(groupName(page)).toContainText('Dirty Dancing Shoes');
  });
});
