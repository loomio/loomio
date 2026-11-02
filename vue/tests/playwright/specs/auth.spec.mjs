import { test, expect } from '../fixtures.mjs';
import { completeAccount, signInViaEmail, signUpViaInvitation } from '../helpers/accounts.mjs';

import { baseUrl } from '../helpers/pageHelper.mjs';

const passkeyAuthenticators = new WeakMap()

const enterLastLoginCode = async page => {
  const code = await (await fetch(`${baseUrl}/dev/last_login_code`)).text()
  await page.fill('.auth-complete__code input', code.trim())
}

// Chromium's virtual authenticator lives on the page's DevTools session and is
// discarded with the page at the end of the test.
const addVirtualPasskeyAuthenticator = async page => {
  const client = await page.context().newCDPSession(page)
  await client.send('WebAuthn.enable')
  const { authenticatorId } = await client.send('WebAuthn.addVirtualAuthenticator', {
    options: {
      protocol: 'ctap2',
      transport: 'usb',
      hasResidentKey: true,
      hasUserVerification: true,
      isUserVerified: true,
    }
  })
  passkeyAuthenticators.set(page, { client, authenticatorId })
}

// Keep the WebAuthn failure visible in CI: the UI intentionally hides a
// cancelled ceremony, and the browser exception is otherwise lost.
const tracePasskeyRegistration = async page => {
  await page.evaluate(() => {
    window.__passkeyDiagnostics = []

    const originalFetch = window.fetch.bind(window)
    window.fetch = async (...args) => {
      const response = await originalFetch(...args)
      const path = new URL(typeof args[0] === 'string' ? args[0] : args[0].url, window.location.href).pathname
      if (path.startsWith('/api/v1/passkey_credentials')) {
        window.__passkeyDiagnostics.push({stage: 'http', path, status: response.status})
      }
      return response
    }

    const originalCreate = navigator.credentials.create.bind(navigator.credentials)
    navigator.credentials.create = async (...args) => {
      window.__passkeyDiagnostics.push({stage: 'webauthn_started'})
      try {
        const credential = await originalCreate(...args)
        window.__passkeyDiagnostics.push({stage: 'webauthn_succeeded'})
        return credential
      } catch (error) {
        window.__passkeyDiagnostics.push({stage: 'webauthn_failed', name: error.name, message: error.message})
        throw error
      }
    }
  })
}

test.afterEach(async ({ page }) => {
  const authenticator = passkeyAuthenticators.get(page)
  if (!authenticator) { return }

  const diagnostics = await page.evaluate(() => window.__passkeyDiagnostics).catch(() => null)
  if (diagnostics) {
    const { credentials } = await authenticator.client.send('WebAuthn.getCredentials', { authenticatorId: authenticator.authenticatorId })
    console.log(`Passkey diagnostics: ${JSON.stringify(diagnostics)}; virtual credentials: ${credentials.length}`)
  }
})

test('can_register_sign_in_and_remove_a_passkey', async ({ page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.goto('/dev/setup_discussion')
  await page.goto('/profile')
  await tracePasskeyRegistration(page)
  await expect(page.locator('.passkey-settings__name input').first()).toHaveValue(/passkey/i)
  await page.fill('.passkey-settings__name input', 'Test passkey')
  await page.click('.passkey-settings__add')
  await expect(page.locator('.flash-root__message')).toContainText('Passkey added')
  await expect(page.locator('.passkey-settings')).toContainText('Test passkey')

  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--sign-out')
  await expect(page.locator('.auth-modal')).toBeVisible({ timeout: 20000 })
  await page.click('.auth-passkey-button__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.dashboard-page')).toBeVisible({ timeout: 20000 })

  await page.goto('/profile')
  await expect(page.locator('.passkey-settings')).toContainText('Test passkey')
  await page.click('.passkey-settings__remove')
  await expect(page.locator('.flash-root__message')).toContainText('Passkey removed')
  await expect(page.locator('.passkey-settings')).toContainText('You have not added a passkey')
});

test('can_add_a_passkey_after_signing_in_with_a_code', async ({ page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.goto('/dev/setup_login_token_user_with_password')
  await page.locator('.auth-email-form__email input').pressSequentially('password-user@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await expect(page.locator('.auth-complete')).toContainText("If an account exists for password-user@example.com, we'll send a sign-in code")
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await expect(page.locator('.credential-prompt')).toContainText('A passkey lets you sign in quickly')
  await expect(page.locator('.credential-prompt__password')).toBeVisible()
  await tracePasskeyRegistration(page)
  await page.click('.credential-prompt__passkey')
  await expect(page.locator('.flash-root__message')).toContainText('Passkey added')
  await expect(page.locator('.credential-prompt')).toHaveCount(0)
  await page.goto('/profile')
  await expect(page.locator('.passkey-settings')).toContainText('Passkey')
});

test('can_add_a_passkey_after_signing_in_with_a_password', async ({ page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.goto('/dev/setup_login_token_user_with_password')
  await page.locator('.auth-email-form__email input').pressSequentially('password-user@example.com')
  await page.fill('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.credential-prompt')).toContainText('Passkeys')
  await expect(page.locator('.credential-prompt__password')).toHaveCount(0)
  await tracePasskeyRegistration(page)
  await page.click('.credential-prompt__passkey')
  await expect(page.locator('.flash-root__message')).toContainText('Passkey added')
  await expect(page.locator('.credential-prompt')).toHaveCount(0)
  await page.goto('/profile')
  await expect(page.locator('.passkey-settings')).toContainText('Passkey')
});

test('remembers_when_a_password_user_dismisses_the_passkey_offer', async ({ page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.goto('/dev/setup_login_token_user_with_password')
  await page.locator('.auth-email-form__email input').pressSequentially('password-user@example.com')
  await page.fill('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.credential-prompt__passkey')).toBeVisible()
  await page.click('.credential-prompt .dismiss-modal-button')
  await expect(page.locator('.credential-prompt')).toHaveCount(0)

  await page.goto('/profile')
  await expect(page.locator('.passkey-settings')).toBeVisible()
  await page.click('.navbar__sidenav-toggle')
  await page.locator('.sidebar__user-dropdown').last().click()
  await page.locator('.user-dropdown__list-item-button--sign-out').last().click()
  await expect(page.locator('.auth-modal')).toBeVisible({ timeout: 20000 })
  await page.locator('.auth-email-form__email input').pressSequentially('password-user@example.com')
  await page.fill('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.credential-prompt')).toHaveCount(0)
});

test('returning_user_without_recorded_legal_acceptance_can_sign_in', async ({ page }) => {
  await page.goto('/dev/setup_returning_user_without_legal_acceptance')
  await page.locator('.auth-email-form__email input').pressSequentially('returning-no-terms@example.com')
  await page.fill('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.dashboard-page')).toBeVisible()
  await expect(page.locator('.account-completion')).toHaveCount(0)
  await page.reload()
  await expect(page.locator('.dashboard-page')).toBeVisible()
  await expect(page.locator('.account-completion')).toHaveCount(0)
});

test('asks_legacy_sessions_for_a_name_on_page_boot', async ({ page }) => {
  for (const name of [null, '', '   ']) {
    const query = name === null ? '' : `?name=${encodeURIComponent(name)}`
    await page.goto(`/dev/setup_legacy_session_without_name${query}`)
    await expect(page.locator('.account-completion')).toBeVisible()
    await expect(page.locator('.auth-modal')).toHaveCount(0)
    await expect(page.locator('.account-completion__legal-accepted')).toHaveCount(0)
    await expect(page.locator('.account-completion__submit')).toBeDisabled()
    await page.reload()
    await expect(page.locator('.account-completion')).toBeVisible()
    await page.fill('.account-completion__name input', 'Returning Person')
    await page.click('.account-completion__submit')
    await expect(page.locator('.account-completion')).toHaveCount(0)
    await page.reload()
    await expect(page.locator('.account-completion')).toHaveCount(0)
    await page.goto('/profile')
    await expect(page.locator('.profile-page__name-input input')).toHaveValue('Returning Person')
  }
});

test('offers_password_and_passkey_after_code_sign_in_when_account_has_a_passkey', async ({ page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.goto('/dev/setup_login_token_user_with_passkey')
  await page.locator('.auth-email-form__email input').pressSequentially('passkey-user@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await expect(page.locator('.credential-prompt')).toContainText('A passkey lets you sign in quickly')
  await expect(page.locator('.credential-prompt__password')).toBeVisible()
  await expect(page.locator('.credential-prompt__passkey')).toBeVisible()
});

test('can_sign_up_from_try_and_complete_the_account', async ({ page }) => {
  const email = `trial-person-${Date.now()}@example.com`

  await page.goto('/dev/setup_dashboard_as_visitor')
  await page.goto('/try')
  await expect(page.locator('.start-trial-form')).toBeVisible()
  await page.fill('.start-trial-form__name input', 'Trial Person')
  await page.fill('.start-trial-form__email input', email)
  await page.fill('.start-trial-form__group-name input', 'Trial Group')
  await page.click('.start-trial-form__submit')
  await expect(page.locator('.trial-started')).toContainText(`We have created a user account for ${email}`)
  await page.click('.trial-started__sign-in')
  await expect(page.locator('.auth-email-form__email input')).toHaveValue(new RegExp(email))
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await expect(page.locator('.account-completion')).toBeVisible()
  await expect(page.locator('.account-completion__name input')).toHaveValue('Trial Person')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await page.reload()
  await page.goto('/profile')
  await expect(page.locator('.profile-page__name-input input')).toHaveValue('Trial Person')
  await expect(page.locator('.profile-page__email-input input')).toHaveValue(new RegExp(email))
});

test('can_sign_up_a_user', async ({ page }) => {
  await page.goto('/dev/setup_dashboard_as_visitor')
  await page.click('.auth-form__create-account')
  await page.locator('.auth-signup-form__email input').pressSequentially('max_von_sydow@example.com')
  await page.click('.auth-signup-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await expect(page.locator('.auth-complete')).toContainText("We've sent an email to max_von_sydow@example.com")
  await expect(page.locator('.auth-complete__submit')).toContainText('Continue')
  await page.goto('/dev/use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await page.fill('.account-completion__name input', 'Max Von Sydow')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.credential-prompt')).toHaveCount(0)
});

test('offers_sign_in_choices_after_completing_an_account_with_a_code', async ({ page }) => {
  await page.goto('/dev/setup_dashboard_as_visitor')
  await page.click('.auth-form__create-account')
  await page.locator('.auth-signup-form__email input').pressSequentially('new-code-user@example.com')
  await page.click('.auth-signup-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await page.fill('.account-completion__name input', 'New Code User')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await expect(page.locator('.credential-prompt__password')).toBeVisible()
});

test('shows_signup_code_copy_for_an_existing_email', async ({ page }) => {
  await page.goto('/dev/setup_login_token_user_with_password')
  await page.click('.auth-form__create-account')
  await page.locator('.auth-signup-form__email input').pressSequentially('password-user@example.com')
  await page.click('.auth-signup-form__submit')
  await expect(page.locator('.auth-complete')).toContainText("We've sent an email to password-user@example.com")
  await expect(page.locator('.auth-complete__submit')).toContainText('Continue')
});

test('can_sign_up_a_new_user_through_the_discussion_page', async ({ page }) => {
  await page.goto('/dev/view_open_discussion_as_visitor')
  await page.click('.add-comment-panel__sign-in-btn')
  await page.click('.auth-form__create-account')
  await page.locator('.auth-signup-form__email input').pressSequentially('max_von_sydow@example.com')
  await page.click('.auth-signup-form__submit')
  await expect(page.locator('.auth-complete')).toBeVisible()
  await page.goto('/dev/use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await page.fill('.account-completion__name input', 'Max Von Sydow')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
});

test('can_login_via_token', async ({ page }) => {
  await page.goto('/dev/setup_login_token')
  await expect(page.locator('.auth-signin-form__token .lmo-pointer')).toHaveCount(0)
  await page.click('.auth-signin-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
});

test('prompts_login_code_user_without_password_to_set_one', async ({ page }) => {
  await page.goto('/dev/setup_login_token_user_without_password')
  await page.evaluate(() => Object.defineProperty(window, 'PublicKeyCredential', { value: undefined, configurable: true }))
  await page.locator('.auth-email-form__email input').pressSequentially('no-password@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await expect(page.locator('.credential-prompt')).toContainText('Set a password?')
  await expect(page.locator('.credential-prompt__passkey')).toHaveCount(0)
  await page.click('.credential-prompt__password')
  await expect(page.locator('.change-password-form')).toContainText('Set your password')
});

test('offers_to_reset_an_existing_password_after_code_sign_in', async ({ page }) => {
  await page.goto('/dev/setup_login_token_user_with_password')
  await page.evaluate(() => Object.defineProperty(window, 'PublicKeyCredential', { value: undefined, configurable: true }))
  await page.locator('.auth-email-form__email input').pressSequentially('password-user@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await expect(page.locator('.credential-prompt')).toContainText('Would you like to set a new password?')
  await expect(page.locator('.credential-prompt__passkey')).toHaveCount(0)
  await page.click('.credential-prompt__password')
  await expect(page.locator('.change-password-form')).toContainText('Set your password')
});

test('can_dismiss_password_prompt_after_login_code_sign_in', async ({ page }) => {
  await page.goto('/dev/setup_login_token_user_without_password')
  await page.evaluate(() => Object.defineProperty(window, 'PublicKeyCredential', { value: undefined, configurable: true }))
  await page.locator('.auth-email-form__email input').pressSequentially('no-password@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await expect(page.locator('.credential-prompt')).toContainText('Set a password?')
  await page.click('.credential-prompt__dismiss')
  await expect(page.locator('.credential-prompt')).toHaveCount(0)
  await page.reload()
  await expect(page.locator('.credential-prompt')).toHaveCount(0)
});

test('can_use_a_shareable_link', async ({ page }) => {
  await page.goto('/dev/view_closed_group_with_shareable_link')
  await page.click('.auth-form__create-account')
  await page.locator('.auth-signup-form__email input').pressSequentially('max_von_sydow@example.com')
  await page.click('.auth-signup-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await page.goto('/dev/use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await page.fill('.account-completion__name input', 'Max Von Sydow')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.credential-prompt')).toHaveCount(0)
});

test('does_not_log_in_when_password_is_incorrect', async ({ page }) => {
  await page.goto('/dev/setup_explore_as_visitor')
  await page.click('.navbar__sign-in')
  await page.locator('.auth-email-form__email input').pressSequentially('patrick@example.com')
  await page.fill('.auth-email-form__password input', 'w0rstmovie')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.lmo-validation-error__message')).toContainText('Unable to sign you in with those details')
});

test('opens_an_email_form_when_requesting_a_login_code_without_an_address', async ({ page }) => {
  await page.goto('/dev/setup_dashboard_as_visitor')
  await page.click('.auth-email-form__login-link')
  await expect(page.locator('.auth-email-code-form')).toContainText('We’ll send a six-digit code to your email address')
  await page.locator('.auth-email-code-form__email input').pressSequentially('patrick@example.com')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
});

test('prefills_the_create_account_form_from_the_sign_in_email', async ({ page }) => {
  await page.goto('/dev/setup_dashboard_as_visitor')
  await page.locator('.auth-email-form__email input').pressSequentially('new-person@example.com')
  await page.click('.auth-form__create-account')
  await expect(page.locator('.auth-signup-form__email input')).toHaveValue('new-person@example.com')
});

test('does_not_carry_an_invalid_email_into_another_authentication_path', async ({ page }) => {
  await page.goto('/dev/setup_dashboard_as_visitor')
  await page.fill('.auth-email-form__email input', 'not-an-email')
  await page.click('.auth-form__create-account')
  await expect(page.locator('.auth-signup-form__email input').first()).toHaveValue('')

  await page.click('.auth-back-button')
  await page.fill('.auth-email-form__email input', 'still-not-an-email')
  await page.click('.auth-email-form__login-link')
  await expect(page.locator('.auth-email-code-form__email input').first()).toHaveValue('')
});

test('can_go_back_and_correct_the_email_for_a_login_code', async ({ page }) => {
  await page.goto('/dev/setup_dashboard_as_visitor')
  await page.locator('.auth-email-form__email input').pressSequentially('wrong@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await page.click('.auth-back-button')
  await expect(page.locator('.auth-email-form__email input')).toBeVisible()
  await expect(page.locator('.auth-email-form__email input')).toHaveValue('wrong@example.com')
});

test('can_send_login_code_to_user_with_a_password', async ({ page }) => {
  await page.goto('/dev/setup_dashboard_as_visitor')
  await page.locator('.auth-email-form__email input').pressSequentially('patrick@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await page.goto('/dev/use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
});

test('does_not_log_in_an_invalid_token', async ({ page }) => {
  await page.goto('/dev/setup_used_login_token')
  await page.click('.auth-signin-form__submit')
  await expect(page.locator('.lmo-validation-error__message')).toContainText('Click below to send another one')
});

test('can_login_from_the_dashboard', async ({ page }) => {
  await page.goto('/dev/setup_dashboard_as_visitor')
  await signInViaEmail(page, 'jennifer@example.com')
  await expect(page.locator('.dashboard-page')).toBeVisible()
});

test('can_login_from_a_discussion_page', async ({ page }) => {
  await page.goto('/dev/view_open_discussion_as_visitor')
  await page.click('.add-comment-panel__sign-in-btn')
  await page.locator('.auth-email-form__email input').pressSequentially('patrick@example.com')
  await page.fill('.auth-email-form__password input', 'gh0stmovie')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
});

test('can_login_from_the_explore_page', async ({ page }) => {
  await page.goto('/dev/setup_explore_as_visitor')
  await page.click('.navbar__sign-in')
  await page.locator('.auth-email-form__email input').pressSequentially('patrick@example.com')
  await page.fill('.auth-email-form__password input', 'gh0stmovie')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
});

test('can_login_from_the_explore_page_via_link', async ({ page }) => {
  await page.goto('/dev/setup_explore_as_visitor')
  await page.click('.navbar__sign-in')
  await page.locator('.auth-email-form__email input').pressSequentially('jennifer@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await page.goto('/dev/use_last_login_token')
  await page.click('.auth-signin-form__submit')

  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
});

test('can_login_from_a_closed_group_page', async ({ page }) => {
  await page.goto('/dev/view_closed_group_as_visitor')
  await page.click('.navbar__sign-in')
  await page.locator('.auth-email-form__email input').pressSequentially('patrick@example.com')
  await page.fill('.auth-email-form__password input', 'gh0stmovie')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.group-page__name')).toContainText('Closed Dirty Dancing Shoes')
  await expect(page.locator('.topic-previews')).toContainText('This thread is private')
});

test('can_login_from_a_secret_group_page', async ({ page }) => {
  await page.goto('/dev/view_secret_group_as_visitor')
  await page.locator('.auth-email-form__email input').pressSequentially('patrick@example.com')
  await page.fill('.auth-email-form__password input', 'gh0stmovie')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.group-page__name')).toContainText('Secret Dirty Dancing Shoes')
});

test('invite_existing_user', async ({ page }) => {
  await page.goto('/dev/setup_invitation_email_to_user_with_password')
  await expect(page.locator('.email-body')).toContainText('Accept invitation')
  await page.click('.email-button')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await page.goto('/dev/use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes')
  await expect(page.locator('.join-group-button')).toHaveCount(0)
});

test('invite_new_user', async ({ page }) => {
  await page.goto('/dev/setup_invitation_email_to_visitor')
  await expect(page.locator('.email-body')).toContainText('Accept invitation')
  await page.click('.email-button')
  await signUpViaInvitation(page, 'Billy Jeans')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes')
});

test('requires_verification_if_email_is_changed', async ({ page }) => {
  await page.goto('/dev/setup_invitation_email_to_visitor')
  await expect(page.locator('.email-body')).toContainText('Accept invitation')
  await page.click('.email-button')
  await page.click('.auth-form__create-account')
  await page.fill('.auth-signup-form__email input', '')
  await page.locator('.auth-signup-form__email input').pressSequentially('max_von_sydow@merciless.com')
  await expect(page.locator('.auth-signup-form')).toContainText('New to')
  await page.click('.auth-signup-form__submit')
  await expect(page.locator('.auth-complete')).toContainText('Check your email')
  await page.goto('/dev/use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await completeAccount(page, 'Billy Jeans')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
});

test('invite_existing_user_via_alternative_email_address', async ({ page }) => {
  await page.goto('/dev/setup_invite_user_with_alternative_email')
  await expect(page.locator('.email-body')).toContainText('Accept invitation')
  await page.click('.email-button')
  await expect(page.locator('.auth-form')).toContainText('If you are already a Loomio user, sign in with your existing account')
  await page.fill('.auth-email-form__email input', '')
  await page.locator('.auth-email-form__email input').pressSequentially('existing-user@example.com')
  await page.fill('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes')
});

test('invite_existing_user_via_alternative_email_address_signed_in', async ({ page }) => {
  await page.goto('/dev/setup_invite_user_with_alternative_email?signed_in=1')
  await expect(page.locator('.email-body')).toContainText('Accept invitation')
  await page.click('.email-button')
  await expect(page.locator('.auth-modal')).toHaveCount(0)
  await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes')
});

test('invite_existing_user_via_correct_email_address', async ({ page }) => {
  await page.goto('/dev/setup_invite_user_with_correct_email')
  await expect(page.locator('.email-body')).toContainText('Accept invitation')
  await page.click('.email-button')
  await page.fill('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes')
});

test('invite_existing_user_via_correct_email_address_signed_in', async ({ page }) => {
  await page.goto('/dev/setup_invite_user_with_correct_email?signed_in=1')
  await expect(page.locator('.email-body')).toContainText('Accept invitation')
  await page.click('.email-button')
  await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes')
});

