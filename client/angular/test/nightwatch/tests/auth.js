require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'can sign up a user': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'max_von_sydow@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signup-form__name input', 'Max Von Sydow')
    page.click('.auth-signup-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.expectText('.auth-complete', 'instantly log in')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.dashboard-page__heading', 'Recent Threads')
  },

  'can sign up a new user through the discussion page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_discussion_as_visitor')
    page.click('.add-comment-panel__sign-in-btn')
    page.fillIn('.auth-email-form__email input', 'max_von_sydow@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signup-form__name input', 'Max Von Sydow')
    page.click('.auth-signup-form__submit')
    page.expectElement('.auth-complete')

    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.context-panel__heading', 'I carried a watermelon')
    page.click('.add-comment-panel__join-actions button')
    page.pause(2000)
    page.expectText('.flash-root__message', 'You are now a member of Open Dirty Dancing Shoes')
    page.expectElement('.comment-form__submit-button')
  },

  'can login via token': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
  },

  'can use a shareable link': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_with_shareable_link')
    page.fillIn('.auth-email-form__email input', 'max_von_sydow@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signup-form__name input', 'Max Von Sydow')
    page.click('.auth-signup-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.expectText('.auth-complete', 'instantly log in')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.group-theme__name', 'Dirty Dancing Shoes')
  },

  'does not log in when password is incorrect': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_explore_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'w0rstmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.auth-form', 'that password doesn\'t match')
  },

  'can send login link to user with a password': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.click('.auth-signin-form__login-link')
    page.expectText('.auth-complete', 'Check your email')
    page.expectText('.auth-complete', 'instantly log in')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.dashboard-page__heading', 'Recent Threads')
  },

  'does not log in an invalid token': (test) => {
    page.loadPath('setup_used_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.lmo-validation-error__message', 'Click below to send another one')
    page.click('.auth-signin-form__submit')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
  },

  'can login from the dashboard': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard_as_visitor')
    page.fillIn('.auth-email-form__email input', 'jennifer_grey@example.com')
    page.click('.auth-email-form__submit')
    page.click('.auth-signin-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.expectText('.auth-complete', 'instantly log in')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.dashboard-page__heading', 'Recent Threads')
  },

  'can login from a discussion page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_discussion_as_visitor')
    page.click('.add-comment-panel__sign-in-btn')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'gh0stmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.fillIn('.comment-form textarea', 'I am new!')
    page.click('.comment-form__submit-button')
    page.pause(2000)
    page.expectText('.flash-root__message', 'Comment added')
  },

  'can login from the explore page': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_explore_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'gh0stmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
  },

  'can login from the explore page via link': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_explore_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'jennifer_grey@example.com')
    page.click('.auth-email-form__submit')
    page.click('.auth-signin-form__submit')
    page.expectText('.auth-complete', 'Check your email')
    page.expectText('.auth-complete', 'instantly log in')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.explore-page', 'Explore groups')
  },

  'can login from a closed group page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_as_visitor')
    page.click('.navbar__sign-in')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'gh0stmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.group-theme__name', 'Closed Dirty Dancing Shoes')
    page.expectText('.thread-preview-collection__container', 'This thread is private')
    page.expectElement('.sidebar__content')
  },

  'can login from a secret group page': (test) => {
    page = pageHelper(test)

    page.loadPath('view_secret_group_as_visitor')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'gh0stmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.group-theme__name', 'Secret Dirty Dancing Shoes')
    page.expectElement('.sidebar__content')
  },

  'can accept an invitation': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_invitation_to_user_with_password')
    page.click('.auth-email-form__submit')
    page.fillIn('.auth-signin-form__password input', 'gh0stmovie')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.group-theme__name', 'Dirty Dancing Shoes')
    page.expectNoElement('.join-group-button')
  },

  'can log someone in from an invitation': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_invitation_to_visitor')
    page.click('.auth-email-form__submit')
    page.expectText('.auth-signup-form', 'Nice to meet you, Max Von Sydow')
    page.click('.auth-signup-form__submit')
    page.expectElement('.auth-complete')
    page.loadPath('use_last_login_token')
    page.click('.auth-signin-form__submit')
    page.expectText('.flash-root__message', 'Signed in successfully')
    page.expectText('.group-theme__name', 'Dirty Dancing Shoes')
  },

  'prompts the user to contact us to reactivate': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_deactivated_user')
    page.fillIn('.auth-email-form__email input', 'patrick_swayze@example.com')
    page.click('.auth-email-form__submit')
    page.expectText('.auth-inactive-form', 'has been deactivated!')
    page.click('.auth-inactive-form__submit')
    page.expectElement('.contact-form')
  }
}
