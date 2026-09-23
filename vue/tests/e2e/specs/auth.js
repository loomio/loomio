pageHelper = require('../helpers/pageHelper')
const http = require('http')
const {Protocol, Transport, VirtualAuthenticatorOptions} = require('selenium-webdriver/lib/virtual_authenticator')

const port = process.env.E2E_PORT || (process.env.RAILS_ENV === 'test' ? '3001' : '8080')
const baseUrl = `http://localhost:${port}`
let virtualAuthenticatorAdded = false

const enterLastLoginCode = (test, page) => {
  test.perform(done => {
    http.get(`${baseUrl}/dev/last_login_code`, res => {
      let body = ''
      res.on('data', chunk => { body += chunk })
      res.on('end', () => {
        page.fillIn('.auth-complete__code input', body.trim())
        done()
      })
    })
  })
}

const addVirtualPasskeyAuthenticator = test => {
  test.perform(async () => {
    const options = new VirtualAuthenticatorOptions()
    options.setProtocol(Protocol.CTAP2)
    options.setTransport(Transport.USB)
    options.setHasResidentKey(true)
    options.setHasUserVerification(true)
    options.setIsUserVerified(true)
    await test.driver.addVirtualAuthenticator(options)
    virtualAuthenticatorAdded = true
  })
}

// Keep the WebAuthn failure visible in CI: the UI intentionally hides a
// cancelled ceremony, and the browser exception is otherwise lost.
const tracePasskeyRegistration = test => {
  test.execute(() => {
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

module.exports = {
  afterEach: async (test) => {
    if (!virtualAuthenticatorAdded) { return }

    try {
      const diagnostics = await test.driver.executeScript('return window.__passkeyDiagnostics')
      if (diagnostics) {
        const credentials = await test.driver.getCredentials()
        console.log(`Passkey diagnostics: ${JSON.stringify(diagnostics)}; virtual credentials: ${credentials.length}`)
      }
    } finally {
      try {
        await test.driver.removeVirtualAuthenticator()
      } finally {
        virtualAuthenticatorAdded = false
      }
    }
  },

  'can_register_sign_in_and_remove_a_passkey': (test) => {
    page = pageHelper(test)
    addVirtualPasskeyAuthenticator(test)

    page.loadPath('setup_discussion')
    page.goTo('profile')
    tracePasskeyRegistration(test)
    test.expect.element('.passkey-settings__name input').value.to.match(/passkey/i)
    page.fillIn('.passkey-settings__name input', 'Test passkey')
    page.scrollClick('.passkey-settings__add')
    page.expectFlash('Passkey added')
    page.expectText('.passkey-settings', 'Test passkey')

    page.ensureSidebar()
    page.click('.sidebar__user-dropdown')
    page.click('.user-dropdown__list-item-button--sign-out')
    page.expectElement('.auth-modal', 20000)
    page.pause(500)
    page.click('.auth-passkey-button__submit')
    page.expectFlash('Signed in successfully')
    page.expectElement('.dashboard-page', 20000)

    page.goTo('profile')
    page.expectText('.passkey-settings', 'Test passkey')
    page.expectElement('.passkey-settings__remove')
    page.scrollClick('.passkey-settings__remove')
    page.acceptConfirm()
    page.expectFlash('Passkey removed')
    page.expectText('.passkey-settings', 'You have not added a passkey')
  },

  'can_add_a_passkey_after_signing_in_with_a_code': (test) => {
    page = pageHelper(test)
    addVirtualPasskeyAuthenticator(test)

    page.loadPath('setup_login_token_user_with_password')
    page.fillIn('.auth-email-form__email input', 'password-user@example.com')
    page.click('.auth-email-form__login-link')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    enterLastLoginCode(test, page)
    page.click('.auth-complete__submit')
    page.expectText('.credential-prompt', 'Passkeys')
    page.expectNoElement('.credential-prompt__password')
    tracePasskeyRegistration(test)
    page.pause(500)
    page.click('.credential-prompt__passkey')
    page.expectFlash('Passkey added')
    page.expectNoElement('.credential-prompt')
    page.goTo('profile')
    page.expectText('.passkey-settings', 'Passkey')
  },

  'can_add_a_passkey_after_signing_in_with_a_password': (test) => {
    page = pageHelper(test)
    addVirtualPasskeyAuthenticator(test)

    page.loadPath('setup_login_token_user_with_password')
    page.fillIn('.auth-email-form__email input', 'password-user@example.com')
    page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
    page.click('.auth-email-form__submit')
    page.expectText('.credential-prompt', 'Passkeys')
    page.expectNoElement('.credential-prompt__password')
    tracePasskeyRegistration(test)
    page.pause(500)
    page.click('.credential-prompt__passkey')
    page.expectFlash('Passkey added')
    page.expectNoElement('.credential-prompt')
    page.goTo('profile')
    page.expectText('.passkey-settings', 'Passkey')
  },

  'returning_user_without_recorded_legal_acceptance_can_sign_in': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_returning_user_without_legal_acceptance')
    page.fillIn('.auth-email-form__email input', 'returning-no-terms@example.com')
    page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
    page.click('.auth-email-form__submit')
    page.expectElement('.dashboard-page')
    page.expectNoElement('.account-completion')
    page.refresh()
    page.expectElement('.dashboard-page')
    page.expectNoElement('.account-completion')
  },

  'does_not_prompt_after_code_sign_in_when_account_has_a_passkey': (test) => {
    page = pageHelper(test)
    addVirtualPasskeyAuthenticator(test)

    page.loadPath('setup_login_token_user_with_passkey')
    page.fillIn('.auth-email-form__email input', 'passkey-user@example.com')
    page.click('.auth-email-form__login-link')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    enterLastLoginCode(test, page)
    page.click('.auth-complete__submit')
    page.pause(500)
    page.expectNoElement('.credential-prompt')
  },

  'can_sign_up_from_try_and_complete_the_account': (test) => {
    page = pageHelper(test)
    const email = `trial-person-${Date.now()}@example.com`

    page.loadPath('setup_dashboard_as_visitor')
    page.goTo('try')
    page.expectElement('.start-trial-form')
    page.fillIn('.start-trial-form__name input', 'Trial Person')
    page.fillIn('.start-trial-form__email input', email)
    page.fillIn('.start-trial-form__group-name input', 'Trial Group')
    page.click('.start-trial-form__category .v-field')
    page.waitFor('.v-overlay--active .v-list-item')
    page.clickLastElement('.v-overlay--active .v-list-item')
    page.click('.start-trial-form__submit')
    page.expectText('.trial-started', `We have created a user account for ${email}`)
    page.click('.trial-started__sign-in')
    page.expectValue('.auth-email-form__email input', email)
    page.click('.auth-email-form__login-link')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    enterLastLoginCode(test, page)
    page.click('.auth-complete__submit')
    page.expectElement('.account-completion')
    page.expectValue('.account-completion__name input', 'Trial Person')
    page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
    page.click('.account-completion__submit')
    page.expectFlash('Signed in successfully')
    page.refreshAndWait()
    page.goTo('profile')
    page.expectValue('.profile-page__name-input input', 'Trial Person')
    page.expectValue('.profile-page__email-input input', email)
  },

  'can_sign_up_a_user': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.click('.auth-form__create-account')
    page.fillIn('.auth-signup-form__email input', 'max_von_sydow@example.com')
    page.click('.auth-signup-form__submit')
    page.expectText('.auth-complete', 'Check your email', 3000)
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.fillIn('.account-completion__name input', 'Max Von Sydow')
    page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
    page.click('.account-completion__submit')
    page.expectFlash('Signed in successfully')
  },

  'can_sign_up_a_new_user_through_the_discussion_page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_discussion_as_visitor')
    page.click('.add-comment-panel__sign-in-btn')
    page.click('.auth-form__create-account')
    page.fillIn('.auth-signup-form__email input', 'max_von_sydow@example.com')
    page.click('.auth-signup-form__submit')
    page.expectElement('.auth-complete')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.fillIn('.account-completion__name input', 'Max Von Sydow')
    page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
    page.click('.account-completion__submit')
    page.expectFlash('Signed in successfully')
    // page.expectText('.context-panel__heading', 'I carried a watermelon')
    // page.click('.add-comment-panel__join-actions button')
    // page.expectFlash('You are now a member of Open Dirty Dancing Shoes')
    // page.expectElement('.comment-form__submit-button')
  },

  'can_login_via_token': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_login_token')
    page.expectNoElement('.auth-signin-form__token .lmo-pointer')
    page.click('.auth-signin-form__submit')
    page.expectFlash('Signed in successfully')
  },

  'prompts_login_code_user_without_password_to_set_one': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_login_token_user_without_password')
    test.execute(() => Object.defineProperty(window, 'PublicKeyCredential', { value: undefined, configurable: true }))
    page.fillIn('.auth-email-form__email input', 'no-password@example.com')
    page.click('.auth-email-form__login-link')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    enterLastLoginCode(test, page)
    page.click('.auth-complete__submit')
    page.expectText('.credential-prompt', 'Set a password?')
    page.expectNoElement('.credential-prompt__passkey')
    page.click('.credential-prompt__password')
    page.expectText('.change-password-form', 'Set your password')
  },

  'can_dismiss_password_prompt_after_login_code_sign_in': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_login_token_user_without_password')
    test.execute(() => Object.defineProperty(window, 'PublicKeyCredential', { value: undefined, configurable: true }))
    page.fillIn('.auth-email-form__email input', 'no-password@example.com')
    page.click('.auth-email-form__login-link')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    enterLastLoginCode(test, page)
    page.click('.auth-complete__submit')
    page.expectText('.credential-prompt', 'Set a password?')
    page.click('.credential-prompt__dismiss')
    page.expectNoElement('.credential-prompt')
    page.refresh()
    page.expectNoElement('.credential-prompt')
  },

  'can_use_a_shareable_link': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_with_shareable_link')
    // page.expectText('.auth-form', 'You have been invited to join Dirty Dancing Shoes')
    page.pause(500)
    page.click('.auth-form__create-account')
    page.fillIn('.auth-signup-form__email input', 'max_von_sydow@example.com')
    page.click('.auth-signup-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.fillIn('.account-completion__name input', 'Max Von Sydow')
    page.click('.account-completion__legal-accepted .v-selection-control__wrapper')
    page.click('.account-completion__submit')
    page.expectFlash('Signed in successfully')
    // page.expectText('.group-page__name', 'Dirty Dancing Shoes')
  },

  'does_not_log_in_when_password_is_incorrect': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_explore_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'patrick@example.com')
    page.fillIn('.auth-email-form__password input', 'w0rstmovie')
    page.click('.auth-email-form__submit')
    page.expectText('.lmo-validation-error__message', 'Unable to sign you in with those details')
  },

  'opens_an_email_form_when_requesting_a_login_code_without_an_address': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.click('.auth-email-form__login-link')
    page.expectText('.auth-email-code-form', 'We’ll send a six-digit code to your email address')
    page.fillIn('.auth-email-code-form__email input', 'patrick@example.com')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
  },

  'prefills_the_create_account_form_from_the_sign_in_email': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'new-person@example.com')
    page.click('.auth-form__create-account')
    page.expectValue('.auth-signup-form__email input', 'new-person@example.com')
  },

  'does_not_carry_an_invalid_email_into_another_authentication_path': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'not-an-email')
    page.click('.auth-form__create-account')
    test.expect.element('.auth-signup-form__email input').value.to.equal('')

    page.click('.auth-back-button')
    page.fillIn('.auth-email-form__email input', 'still-not-an-email')
    page.click('.auth-email-form__login-link')
    test.expect.element('.auth-email-code-form__email input').value.to.equal('')
  },

  'can_go_back_and_correct_the_email_for_a_login_code': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'wrong@example.com')
    page.click('.auth-email-form__login-link')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.click('.auth-back-button')
    page.expectElement('.auth-email-form__email input')
    page.expectValue('.auth-email-form__email input', 'wrong@example.com')
  },

  'can_send_login_code_to_user_with_a_password': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'patrick@example.com')
    page.click('.auth-email-form__login-link')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectFlash('Signed in successfully')
    // page.expectText('.dashboard-page__heading', 'Recent Threads')
  },

  'does_not_log_in_an_invalid_token': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_used_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.lmo-validation-error__message', 'Click below to send another one')
    // page.click('.auth-signin-form__submit')
    // page.loadPath('use_last_login_token')
    // page.pause(1000)
    // page.click('.auth-signin-form__submit')
    // page.pause()
    // page.expectFlash('Signed in successfully')
  },

  'can_login_from_the_dashboard': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.signInViaEmail('jennifer@example.com')
    page.pause(1000)
    page.expectElement('.dashboard-page')
  },

  'can_login_from_a_discussion_page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_discussion_as_visitor')
    page.click('.add-comment-panel__sign-in-btn')
    page.fillIn('.auth-email-form__email input', 'patrick@example.com')
    page.fillIn('.auth-email-form__password input', 'gh0stmovie')
    page.click('.auth-email-form__submit')
    page.expectFlash('Signed in successfully')
    // page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'I am new!')
    // page.click('.dismiss-modal-button')
    // page.click('.comment-form__submit-button')
    // page.expectFlash('Comment added')
  },

  'can_login_from_the_explore_page': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_explore_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'patrick@example.com')
    page.fillIn('.auth-email-form__password input', 'gh0stmovie')
    page.click('.auth-email-form__submit')
    page.expectFlash('Signed in successfully')
  },

  'can_login_from_the_explore_page_via_link': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_explore_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'jennifer@example.com')
    page.click('.auth-email-form__login-link')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')

    page.expectFlash('Signed in successfully')
    // page.expectText('.explore-page', 'Explore groups')
  },

  'can_login_from_a_closed_group_page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'patrick@example.com')
    page.fillIn('.auth-email-form__password input', 'gh0stmovie')
    page.click('.auth-email-form__submit')
    page.expectFlash('Signed in successfully')
    page.expectText('.group-page__name', 'Closed Dirty Dancing Shoes')
    page.expectText('.topic-previews', 'This thread is private')
  },

  'can_login_from_a_secret_group_page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_secret_group_as_visitor')
    page.fillIn('.auth-email-form__email input', 'patrick@example.com')
    page.fillIn('.auth-email-form__password input', 'gh0stmovie')
    page.click('.auth-email-form__submit')
    page.expectFlash('Signed in successfully')
    page.expectText('.group-page__name', 'Secret Dirty Dancing Shoes')
  },

  'invite_existing_user': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_invitation_email_to_user_with_password')
    page.expectText('.email-body', 'Accept invitation')
    page.click('.email-button', 2000)
    page.pause(500)
    page.click('.auth-email-form__login-link')
    page.click('.auth-email-code-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectFlash('Signed in successfully')
    page.expectText('.group-page__name', 'Dirty Dancing Shoes')
    page.expectNoElement('.join-group-button')
  },

  'invite_new_user': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_invitation_email_to_visitor')
    page.expectText('.email-body', 'Accept invitation')
    page.click('.email-button', 2000)
    // page.expectText('.auth-form', 'You have been invited to join Dirty Dancing Shoes')
    page.signUpViaInvitation('Billy Jeans')
    page.expectFlash('Signed in successfully')
    page.expectText('.group-page__name', 'Dirty Dancing Shoes')
  },

  // commented out because selenium clearValue is broken on Chrome.
  'requires_verification_if_email_is_changed': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_invitation_email_to_visitor')
    page.expectText('.email-body', 'Accept invitation')
    page.click('.email-button', 2000)
    page.click('.auth-form__create-account')
    page.clearField('.auth-signup-form__email input')
    page.fillIn('.auth-signup-form__email input', 'max_von_sydow@merciless.com')
    // GK: NB: clearValue is not working right now - so the existing input value is being appended to instead
    // https://github.com/nightwatchjs/nightwatch/issues/1939
    page.expectText('.auth-signup-form', 'New to')
    page.click('.auth-signup-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.completeAccount('Billy Jeans')
    page.expectFlash('Signed in successfully')
    page.click('.credential-prompt__dismiss')
  },

  'invite_existing_user_via_alternative_email_address': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_invite_user_with_alternative_email')
    page.expectText('.email-body', 'Accept invitation')
    page.click('.email-button', 2000)
    page.expectText('.auth-form', 'If you are already a Loomio user, sign in with your existing account')
    page.clearField('.auth-email-form__email input')
    page.fillIn('.auth-email-form__email input', 'existing-user@example.com')
    page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
    page.click('.auth-email-form__submit')
    page.expectFlash('Signed in successfully')
    page.expectText('.group-page__name', 'Dirty Dancing Shoes')
  },

  'invite_existing_user_via_alternative_email_address_signed_in': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_invite_user_with_alternative_email?signed_in=1')
    page.expectText('.email-body', 'Accept invitation')
    page.click('.email-button', 2000)
    page.expectNoElement('.auth-modal')
    page.expectText('.group-page__name', 'Dirty Dancing Shoes')
  },

  'invite_existing_user_via_correct_email_address': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_invite_user_with_correct_email')
    page.expectText('.email-body', 'Accept invitation')
    page.click('.email-button', 2000)
    page.pause(500)
    page.fillIn('.auth-email-form__password input', 'veryeasytoguess123')
    page.click('.auth-email-form__submit')
    page.expectFlash('Signed in successfully')
    page.expectText('.group-page__name', 'Dirty Dancing Shoes')
  },

  'invite_existing_user_via_correct_email_address_signed_in': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_invite_user_with_correct_email?signed_in=1')
    page.expectText('.email-body', 'Accept invitation')
    page.click('.email-button', 2000)
    page.expectText('.group-page__name', 'Dirty Dancing Shoes')
  }

}
