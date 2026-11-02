import { test, expect } from '../fixtures.mjs';

import { baseUrl } from '../helpers/pageHelper.mjs';

const passkeyAuthenticators = new WeakMap()

const enterLastLoginCode = async page => {
  const code = await (await fetch(`${baseUrl}/dev/last_login_code`)).text()
  await page.fillIn('.auth-complete__code input', code.trim())
}

// Chromium's virtual authenticator lives on the page's DevTools session and is
// discarded with the page at the end of the test.
const addVirtualPasskeyAuthenticator = async page => {
  const client = await page.page.context().newCDPSession(page.page)
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
  passkeyAuthenticators.set(page.page, { client, authenticatorId })
}

// Keep the WebAuthn failure visible in CI: the UI intentionally hides a
// cancelled ceremony, and the browser exception is otherwise lost.
const tracePasskeyRegistration = async page => {
  await page.execute(() => {
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

test('can_register_sign_in_and_remove_a_passkey', async ({ lmo: page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.loadPath('setup_discussion')
  await page.goTo('profile')
  await tracePasskeyRegistration(page)
  await expect(page.first('.passkey-settings__name input')).toHaveValue(/passkey/i)
  await page.fillIn('.passkey-settings__name input', 'Test passkey')
  await page.scrollClick('.passkey-settings__add')
  await page.expectFlash('Passkey added')
  await page.expectText('.passkey-settings', 'Test passkey')

  await page.ensureSidebar()
  await page.click('.sidebar__user-dropdown')
  await page.click('.user-dropdown__list-item-button--sign-out')
  await page.expectElement('.auth-modal', 20000)
  await page.pause(500)
  await page.click('.auth-passkey-button__submit')
  await page.expectFlash('Signed in successfully')
  await page.expectElement('.dashboard-page', 20000)

  await page.goTo('profile')
  await page.expectText('.passkey-settings', 'Test passkey')
  await page.expectElement('.passkey-settings__remove')
  await page.scrollClick('.passkey-settings__remove')
  await page.acceptConfirm()
  await page.expectFlash('Passkey removed')
  await page.expectText('.passkey-settings', 'You have not added a passkey')
});

test('can_add_a_passkey_after_signing_in_with_a_code', async ({ lmo: page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.loadPath('setup_login_token_user_with_password')
  await page.fillIn('.auth-email-form__email input', 'password-user@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await page.expectText('.auth-complete', "If an account exists for password-user@example.com, we'll send a sign-in code")
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await page.expectText('.credential-prompt', 'A passkey lets you sign in quickly')
  await page.expectElement('.credential-prompt__password')
  await tracePasskeyRegistration(page)
  await page.pause(500)
  await page.click('.credential-prompt__passkey')
  await page.expectFlash('Passkey added')
  await page.expectNoElement('.credential-prompt')
  await page.goTo('profile')
  await page.expectText('.passkey-settings', 'Passkey')
});

test('can_add_a_passkey_after_signing_in_with_a_password', async ({ lmo: page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.loadPath('setup_login_token_user_with_password')
  await page.fillIn('.auth-email-form__email input', 'password-user@example.com')
  await page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await page.expectText('.credential-prompt', 'Passkeys')
  await page.expectNoElement('.credential-prompt__password')
  await tracePasskeyRegistration(page)
  await page.pause(500)
  await page.click('.credential-prompt__passkey')
  await page.expectFlash('Passkey added')
  await page.expectNoElement('.credential-prompt')
  await page.goTo('profile')
  await page.expectText('.passkey-settings', 'Passkey')
});

test('remembers_when_a_password_user_dismisses_the_passkey_offer', async ({ lmo: page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.loadPath('setup_login_token_user_with_password')
  await page.fillIn('.auth-email-form__email input', 'password-user@example.com')
  await page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await page.expectElement('.credential-prompt__passkey')
  await page.click('.credential-prompt .dismiss-modal-button')
  await page.expectNoElement('.credential-prompt')

  await page.goTo('profile')
  await page.expectElement('.passkey-settings')
  await page.ensureSidebar()
  await page.clickLastElement('.sidebar__user-dropdown')
  await page.clickLastElement('.user-dropdown__list-item-button--sign-out')
  await page.expectElement('.auth-modal', 20000)
  await page.fillIn('.auth-email-form__email input', 'password-user@example.com')
  await page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await page.expectFlash('Signed in successfully')
  await page.pause(500)
  await page.expectNoElement('.credential-prompt')
});

test('returning_user_without_recorded_legal_acceptance_can_sign_in', async ({ lmo: page }) => {
  await page.loadPath('setup_returning_user_without_legal_acceptance')
  await page.fillIn('.auth-email-form__email input', 'returning-no-terms@example.com')
  await page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await page.expectElement('.dashboard-page')
  await page.expectNoElement('.account-completion')
  await page.refresh()
  await page.expectElement('.dashboard-page')
  await page.expectNoElement('.account-completion')
});

test('asks_legacy_sessions_for_a_name_on_page_boot', async ({ lmo: page }) => {
  for (const name of [null, '', '   ']) {
    const query = name === null ? '' : `?name=${encodeURIComponent(name)}`
    await page.loadPath(`setup_legacy_session_without_name${query}`)
    await page.expectElement('.account-completion')
    await page.expectNoElement('.auth-modal')
    await page.expectNoElement('.account-completion__legal-accepted')
    await page.expectDisabled('.account-completion__submit')
    await page.refreshAndWait()
    await page.expectElement('.account-completion')
    await page.fillIn('.account-completion__name input', 'Returning Person')
    await page.click('.account-completion__submit')
    await page.expectNoElement('.account-completion')
    await page.refreshAndWait()
    await page.expectNoElement('.account-completion')
    await page.goTo('profile')
    await page.expectValue('.profile-page__name-input input', 'Returning Person')
  }
});

test('offers_password_and_passkey_after_code_sign_in_when_account_has_a_passkey', async ({ lmo: page }) => {
  await addVirtualPasskeyAuthenticator(page)

  await page.loadPath('setup_login_token_user_with_passkey')
  await page.fillIn('.auth-email-form__email input', 'passkey-user@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await page.expectText('.credential-prompt', 'A passkey lets you sign in quickly')
  await page.expectElement('.credential-prompt__password')
  await page.expectElement('.credential-prompt__passkey')
});

test('can_sign_up_from_try_and_complete_the_account', async ({ lmo: page }) => {
  const email = `trial-person-${Date.now()}@example.com`

  await page.loadPath('setup_dashboard_as_visitor')
  await page.goTo('try')
  await page.expectElement('.start-trial-form')
  await page.fillIn('.start-trial-form__name input', 'Trial Person')
  await page.fillIn('.start-trial-form__email input', email)
  await page.fillIn('.start-trial-form__group-name input', 'Trial Group')
  await page.click('.start-trial-form__submit')
  await page.expectText('.trial-started', `We have created a user account for ${email}`)
  await page.click('.trial-started__sign-in')
  await page.expectValue('.auth-email-form__email input', email)
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await page.expectElement('.account-completion')
  await page.expectValue('.account-completion__name input', 'Trial Person')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await page.expectFlash('Signed in successfully')
  await page.refreshAndWait()
  await page.goTo('profile')
  await page.expectValue('.profile-page__name-input input', 'Trial Person')
  await page.expectValue('.profile-page__email-input input', email)
});

test('can_sign_up_a_user', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard_as_visitor')
  await page.click('.auth-form__create-account')
  await page.fillIn('.auth-signup-form__email input', 'max_von_sydow@example.com')
  await page.click('.auth-signup-form__submit')
  await page.expectText('.auth-complete', 'Check your email', 3000)
  await page.expectText('.auth-complete', "We've sent an email to max_von_sydow@example.com")
  await page.expectText('.auth-complete__submit', 'Continue')
  await page.loadPath('use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await page.fillIn('.account-completion__name input', 'Max Von Sydow')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await page.expectFlash('Signed in successfully')
  await page.pause(500)
  await page.expectNoElement('.credential-prompt')
});

test('offers_sign_in_choices_after_completing_an_account_with_a_code', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard_as_visitor')
  await page.click('.auth-form__create-account')
  await page.fillIn('.auth-signup-form__email input', 'new-code-user@example.com')
  await page.click('.auth-signup-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await page.fillIn('.account-completion__name input', 'New Code User')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await page.expectElement('.credential-prompt__password')
});

test('shows_signup_code_copy_for_an_existing_email', async ({ lmo: page }) => {
  await page.loadPath('setup_login_token_user_with_password')
  await page.click('.auth-form__create-account')
  await page.fillIn('.auth-signup-form__email input', 'password-user@example.com')
  await page.click('.auth-signup-form__submit')
  await page.expectText('.auth-complete', "We've sent an email to password-user@example.com")
  await page.expectText('.auth-complete__submit', 'Continue')
});

test('can_sign_up_a_new_user_through_the_discussion_page', async ({ lmo: page }) => {
  await page.loadPath('view_open_discussion_as_visitor')
  await page.click('.add-comment-panel__sign-in-btn')
  await page.click('.auth-form__create-account')
  await page.fillIn('.auth-signup-form__email input', 'max_von_sydow@example.com')
  await page.click('.auth-signup-form__submit')
  await page.expectElement('.auth-complete')
  await page.loadPath('use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await page.fillIn('.account-completion__name input', 'Max Von Sydow')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await page.expectFlash('Signed in successfully')
  // page.expectText('.context-panel__heading', 'I carried a watermelon')
  // page.click('.add-comment-panel__join-actions button')
  // page.expectFlash('You are now a member of Open Dirty Dancing Shoes')
  // page.expectElement('.comment-form__submit-button')
});

test('can_login_via_token', async ({ lmo: page }) => {
  await page.loadPath('setup_login_token')
  await page.expectNoElement('.auth-signin-form__token .lmo-pointer')
  await page.click('.auth-signin-form__submit')
  await page.expectFlash('Signed in successfully')
});

test('prompts_login_code_user_without_password_to_set_one', async ({ lmo: page }) => {
  await page.loadPath('setup_login_token_user_without_password')
  await page.execute(() => Object.defineProperty(window, 'PublicKeyCredential', { value: undefined, configurable: true }))
  await page.fillIn('.auth-email-form__email input', 'no-password@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await page.expectText('.credential-prompt', 'Set a password?')
  await page.expectNoElement('.credential-prompt__passkey')
  await page.click('.credential-prompt__password')
  await page.expectText('.change-password-form', 'Set your password')
});

test('offers_to_reset_an_existing_password_after_code_sign_in', async ({ lmo: page }) => {
  await page.loadPath('setup_login_token_user_with_password')
  await page.execute(() => Object.defineProperty(window, 'PublicKeyCredential', { value: undefined, configurable: true }))
  await page.fillIn('.auth-email-form__email input', 'password-user@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await page.expectText('.credential-prompt', 'Would you like to set a new password?')
  await page.expectNoElement('.credential-prompt__passkey')
  await page.click('.credential-prompt__password')
  await page.expectText('.change-password-form', 'Set your password')
});

test('can_dismiss_password_prompt_after_login_code_sign_in', async ({ lmo: page }) => {
  await page.loadPath('setup_login_token_user_without_password')
  await page.execute(() => Object.defineProperty(window, 'PublicKeyCredential', { value: undefined, configurable: true }))
  await page.fillIn('.auth-email-form__email input', 'no-password@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await enterLastLoginCode(page)
  await page.click('.auth-complete__submit')
  await page.expectText('.credential-prompt', 'Set a password?')
  await page.click('.credential-prompt__dismiss')
  await page.expectNoElement('.credential-prompt')
  await page.refresh()
  await page.expectNoElement('.credential-prompt')
});

test('can_use_a_shareable_link', async ({ lmo: page }) => {
  await page.loadPath('view_closed_group_with_shareable_link')
  // page.expectText('.auth-form', 'You have been invited to join Dirty Dancing Shoes')
  await page.pause(500)
  await page.click('.auth-form__create-account')
  await page.fillIn('.auth-signup-form__email input', 'max_von_sydow@example.com')
  await page.click('.auth-signup-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await page.loadPath('use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await page.fillIn('.account-completion__name input', 'Max Von Sydow')
  await page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
  await page.click('.account-completion__submit')
  await page.expectFlash('Signed in successfully')
  await page.pause(500)
  await page.expectNoElement('.credential-prompt')
  // page.expectText('.group-page__name', 'Dirty Dancing Shoes')
});

test('does_not_log_in_when_password_is_incorrect', async ({ lmo: page }) => {
  await page.loadPath('setup_explore_as_visitor')
  await page.click('.navbar__sign-in')
  await page.fillIn('.auth-email-form__email input', 'patrick@example.com')
  await page.fillIn('.auth-email-form__password input', 'w0rstmovie')
  await page.click('.auth-email-form__submit')
  await page.expectText('.lmo-validation-error__message', 'Unable to sign you in with those details')
});

test('opens_an_email_form_when_requesting_a_login_code_without_an_address', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard_as_visitor')
  await page.click('.auth-email-form__login-link')
  await page.expectText('.auth-email-code-form', 'We’ll send a six-digit code to your email address')
  await page.fillIn('.auth-email-code-form__email input', 'patrick@example.com')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
});

test('prefills_the_create_account_form_from_the_sign_in_email', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard_as_visitor')
  await page.fillIn('.auth-email-form__email input', 'new-person@example.com')
  await page.click('.auth-form__create-account')
  await page.expectValue('.auth-signup-form__email input', 'new-person@example.com')
});

test('does_not_carry_an_invalid_email_into_another_authentication_path', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard_as_visitor')
  await page.fillIn('.auth-email-form__email input', 'not-an-email')
  await page.click('.auth-form__create-account')
  await expect(page.first('.auth-signup-form__email input')).toHaveValue('')

  await page.click('.auth-back-button')
  await page.fillIn('.auth-email-form__email input', 'still-not-an-email')
  await page.click('.auth-email-form__login-link')
  await expect(page.first('.auth-email-code-form__email input')).toHaveValue('')
});

test('can_go_back_and_correct_the_email_for_a_login_code', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard_as_visitor')
  await page.fillIn('.auth-email-form__email input', 'wrong@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await page.click('.auth-back-button')
  await page.expectElement('.auth-email-form__email input')
  await page.expectValue('.auth-email-form__email input', 'wrong@example.com')
});

test('can_send_login_code_to_user_with_a_password', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard_as_visitor')
  await page.fillIn('.auth-email-form__email input', 'patrick@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await page.loadPath('use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await page.expectFlash('Signed in successfully')
  // page.expectText('.dashboard-page__heading', 'Recent Threads')
});

test('does_not_log_in_an_invalid_token', async ({ lmo: page }) => {
  await page.loadPath('setup_used_login_token')
  await page.click('.auth-signin-form__submit')
  await page.expectText('.lmo-validation-error__message', 'Click below to send another one')
  // page.click('.auth-signin-form__submit')
  // page.loadPath('use_last_login_token')
  // page.pause(1000)
  // page.click('.auth-signin-form__submit')
  // page.pause()
  // page.expectFlash('Signed in successfully')
});

test('can_login_from_the_dashboard', async ({ lmo: page }) => {
  await page.loadPath('setup_dashboard_as_visitor')
  await page.signInViaEmail('jennifer@example.com')
  await page.pause(1000)
  await page.expectElement('.dashboard-page')
});

test('can_login_from_a_discussion_page', async ({ lmo: page }) => {
  await page.loadPath('view_open_discussion_as_visitor')
  await page.click('.add-comment-panel__sign-in-btn')
  await page.fillIn('.auth-email-form__email input', 'patrick@example.com')
  await page.fillIn('.auth-email-form__password input', 'gh0stmovie')
  await page.click('.auth-email-form__submit')
  await page.expectFlash('Signed in successfully')
  // page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'I am new!')
  // page.click('.dismiss-modal-button')
  // page.click('.comment-form__submit-button')
  // page.expectFlash('Comment added')
});

test('can_login_from_the_explore_page', async ({ lmo: page }) => {
  await page.loadPath('setup_explore_as_visitor')
  await page.click('.navbar__sign-in')
  await page.fillIn('.auth-email-form__email input', 'patrick@example.com')
  await page.fillIn('.auth-email-form__password input', 'gh0stmovie')
  await page.click('.auth-email-form__submit')
  await page.expectFlash('Signed in successfully')
});

test('can_login_from_the_explore_page_via_link', async ({ lmo: page }) => {
  await page.loadPath('setup_explore_as_visitor')
  await page.click('.navbar__sign-in')
  await page.fillIn('.auth-email-form__email input', 'jennifer@example.com')
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await page.loadPath('use_last_login_token')
  await page.click('.auth-signin-form__submit')

  await page.expectFlash('Signed in successfully')
  // page.expectText('.explore-page', 'Explore groups')
});

test('can_login_from_a_closed_group_page', async ({ lmo: page }) => {
  await page.loadPath('view_closed_group_as_visitor')
  await page.click('.navbar__sign-in')
  await page.fillIn('.auth-email-form__email input', 'patrick@example.com')
  await page.fillIn('.auth-email-form__password input', 'gh0stmovie')
  await page.click('.auth-email-form__submit')
  await page.expectFlash('Signed in successfully')
  await page.expectText('.group-page__name', 'Closed Dirty Dancing Shoes')
  await page.expectText('.topic-previews', 'This thread is private')
});

test('can_login_from_a_secret_group_page', async ({ lmo: page }) => {
  await page.loadPath('view_secret_group_as_visitor')
  await page.fillIn('.auth-email-form__email input', 'patrick@example.com')
  await page.fillIn('.auth-email-form__password input', 'gh0stmovie')
  await page.click('.auth-email-form__submit')
  await page.expectFlash('Signed in successfully')
  await page.expectText('.group-page__name', 'Secret Dirty Dancing Shoes')
});

test('invite_existing_user', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_invitation_email_to_user_with_password')
  await page.expectText('.email-body', 'Accept invitation')
  await page.click('.email-button', 2000)
  await page.pause(500)
  await page.click('.auth-email-form__login-link')
  await page.click('.auth-email-code-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await page.loadPath('use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await page.expectFlash('Signed in successfully')
  await page.expectText('.group-page__name', 'Dirty Dancing Shoes')
  await page.expectNoElement('.join-group-button')
});

test('invite_new_user', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_invitation_email_to_visitor')
  await page.expectText('.email-body', 'Accept invitation')
  await page.click('.email-button', 2000)
  // page.expectText('.auth-form', 'You have been invited to join Dirty Dancing Shoes')
  await page.signUpViaInvitation('Billy Jeans')
  await page.expectFlash('Signed in successfully')
  await page.expectText('.group-page__name', 'Dirty Dancing Shoes')
});

  // commented out because selenium clearValue is broken on Chrome.
test('requires_verification_if_email_is_changed', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_invitation_email_to_visitor')
  await page.expectText('.email-body', 'Accept invitation')
  await page.click('.email-button', 2000)
  await page.click('.auth-form__create-account')
  await page.clearField('.auth-signup-form__email input')
  await page.fillIn('.auth-signup-form__email input', 'max_von_sydow@merciless.com')
  await page.expectText('.auth-signup-form', 'New to')
  await page.click('.auth-signup-form__submit')
  await page.expectText('.auth-complete', 'Check your email')
  await page.loadPath('use_last_login_token')
  await page.click('.auth-signin-form__submit')
  await page.completeAccount('Billy Jeans')
  await page.expectFlash('Signed in successfully')
});

test('invite_existing_user_via_alternative_email_address', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_invite_user_with_alternative_email')
  await page.expectText('.email-body', 'Accept invitation')
  await page.click('.email-button', 2000)
  await page.expectText('.auth-form', 'If you are already a Loomio user, sign in with your existing account')
  await page.clearField('.auth-email-form__email input')
  await page.fillIn('.auth-email-form__email input', 'existing-user@example.com')
  await page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await page.expectFlash('Signed in successfully')
  await page.expectText('.group-page__name', 'Dirty Dancing Shoes')
});

test('invite_existing_user_via_alternative_email_address_signed_in', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_invite_user_with_alternative_email?signed_in=1')
  await page.expectText('.email-body', 'Accept invitation')
  await page.click('.email-button', 2000)
  await page.expectNoElement('.auth-modal')
  await page.expectText('.group-page__name', 'Dirty Dancing Shoes')
});

test('invite_existing_user_via_correct_email_address', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_invite_user_with_correct_email')
  await page.expectText('.email-body', 'Accept invitation')
  await page.click('.email-button', 2000)
  await page.pause(500)
  await page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
  await page.click('.auth-email-form__submit')
  await page.expectFlash('Signed in successfully')
  await page.expectText('.group-page__name', 'Dirty Dancing Shoes')
});

test('invite_existing_user_via_correct_email_address_signed_in', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_invite_user_with_correct_email?signed_in=1')
  await page.expectText('.email-body', 'Accept invitation')
  await page.click('.email-button', 2000)
  await page.expectText('.group-page__name', 'Dirty Dancing Shoes')
});

