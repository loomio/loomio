require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'can_sign_up_a_user': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'max_von_sydow@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signup-form__name input', 'Max Von Sydow')
    page.click('.auth-signup-form__legal-accepted label')
    page.click('.auth-signup-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.dashboard-page__heading', 'Recent Threads')
  },

  'can_sign_up_a_new_user_through_the_discussion_page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_discussion_as_visitor')
    page.click('.add-comment-panel__sign-in-btn')
    page.fillIn('.auth-email-form__email input', 'max_von_sydow@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signup-form__name input', 'Max Von Sydow')
    page.click('.auth-signup-form__legal-accepted label')
    page.click('.auth-signup-form__submit')
    page.expectElement('.auth-complete')

    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    // TODO: GK: component is not updating after user has logged in
    // page.expectText('.context-panel__heading', 'I carried a watermelon')
    // page.click('.add-comment-panel__join-actions button')
    // page.pause(2000)
    // page.expectText('.flash-root__message', 'You are now a member of Open Dirty Dancing Shoes')
    // page.expectElement('.comment-form__submit-button')
  },

  'can_login_via_token': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully', 20000)
  },

  'can_use_a_shareable_link': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_with_shareable_link')
    // TODO: GK: the redirect from memberships controller's join method isn't being overridden, as it doesn't use the dev controller
    page.fillIn('.auth-email-form__email input', 'max_von_sydow@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signup-form__name input', 'Max Von Sydow')
    page.click('.auth-signup-form__legal-accepted label')
    page.click('.auth-signup-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.group-theme__name', 'Dirty Dancing Shoes')
  },

  'does_not_log_in_when_password_is_incorrect': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_explore_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'w0rstmovie')
    page.click('.auth-signin-form__submit')
    page.pause(1000)
    page.expectText('.auth-form', "that password doesn't match")
  },

  'can_send_login_link_to_user_with_a_password': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.click('.auth-signin-form__login-link')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.dashboard-page__heading', 'Recent Threads')
  },

  'does_not_log_in_an_invalid_token': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_used_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.lmo-validation-error__message', 'Click below to send another one')
    page.click('.auth-signin-form__submit')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
  },

  'can_login_from_the_dashboard': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'jennifer_grey@example.com')
    page.click('.auth-email-form__submit')
    page.click('.auth-signin-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.dashboard-page__heading', 'Recent Threads')
  },

  'can_login_from_a_discussion_page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_discussion_as_visitor')
    page.click('.add-comment-panel__sign-in-btn')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'gh0stmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    // TODO: GK: again, component not updating on login
    page.fillIn('.comment-form textarea', 'I am new!')
    page.click('.comment-form__submit-button')
    page.pause(2000)
    page.expectText('.flash-root__message', 'Comment added')
  },

  'can_login_from_the_explore_page': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_explore_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'gh0stmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
  },

  'can_login_from_the_explore_page_via_link': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_explore_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'jennifer_grey@example.com')
    page.click('.auth-email-form__submit')
    page.click('.auth-signin-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')

    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.explore-page', 'Explore groups')
  },

  'can_login_from_a_closed_group_page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'gh0stmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    // GK: TODO: same problem as before - component doesn't react to user being logged in
    page.expectText('.group-theme__name', 'Closed Dirty Dancing Shoes')
    page.expectText('.thread-preview-collection__container', 'This thread is private')
    page.ensureSidebar()
    page.expectElement('.sidebar__content')
  },

  'can_login_from_a_secret_group_page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_secret_group_as_visitor')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'gh0stmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    // TODO: GK: once again, group page does not update when user has logged in
    page.expectText('.group-theme__name', 'Secret Dirty Dancing Shoes')
    page.ensureSidebar()
    page.expectElement('.sidebar__content')
  },

  'can_invite_existing_user': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_invitation_to_user_with_password')
    page.click('.auth-email-form__submit')
    page.expectText('.auth-signin-form', 'Welcome back, Jennifer!')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.group-theme__name', 'Dirty Dancing Shoes')
    // TODO: GK: once again, group page does not update when user has logged in
    page.expectNoElement('.join-group-button')
  },

  'can_invite_new_user': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_invitation_to_visitor')
    page.click('.auth-email-form__submit')
    page.expectText('.auth-signup-form', 'New to')
    page.fillIn('.auth-signup-form__name input', 'Billy Jeans')
    page.click('.auth-signup-form__legal-accepted label')
    page.click('.auth-signup-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully', 8000)
    page.expectText('.group-theme__name', 'Dirty Dancing Shoes', 16000)
  },

  'requires_verification_if_email_is_changed': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_invitation_to_visitor')
    page.fillIn('.auth-email-form__email input', 'max_von_sydow@merciless.com')
    // GK: NB: clearValue is not working right now - so the existing input value is being appended to instead
    // https://github.com/nightwatchjs/nightwatch/issues/1939
    page.click('.auth-email-form__submit')
    page.expectText('.auth-signup-form', 'New to')
    page.fillIn('.auth-signup-form__name input', 'Billy Jeans')
    page.click('.auth-signup-form__legal-accepted label')
    page.click('.auth-signup-form__submit')
    page.expectText('.auth-complete', 'Check your email')
  },

  'prompts_reactivation_if_required': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_deactivated_user')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.expectText('.auth-inactive-form', 'has been deactivated')
    page.expectElement('.auth-inactive-form__reactivate')
  },

  'can_reactivate_the_account': (test) =>  {
    page = pageHelper(test)

    page.loadPath('setup_user_reactivation_email')
    // TODO: GK: user_reactivated template uses login_token_url which provides a url for localhost:3000
    page.click('.base-mailer__button')
    page.pause(2000)
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
  }

}
