describe 'Login', ->
  page = require './helpers/page_helper.coffee'

  fdescribe 'logging in as an existing user', ->
    it 'forces login on dashboard', ->
      page.loadPath 'setup_dashboard_as_visitor'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'gh0stmovie'
      page.click '.auth-signin-form__submit'
      page.expectElement '.sidebar__content'
      page.expectFlash 'Signed in successfully'

    it 'can log in from the explore page', ->
      page.loadPath 'setup_explore_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'gh0stmovie'
      page.click '.auth-signin-form__submit'
      page.expectElement '.sidebar__content'
      page.expectFlash 'Signed in successfully'

    it 'can log in from a discussion page', ->
      page.loadPath 'view_open_discussion_as_visitor'
      page.click '.comment-form__sign-in-btn'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'gh0stmovie'
      page.click '.auth-signin-form__submit'
      page.expectElement '.sidebar__content'
      page.expectElement '.comment-form__submit-button'
      page.expectFlash 'Signed in successfully'

    it 'can send login link', ->
      page.loadPath 'setup_dashboard_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'jennifer_grey@example.com'
      page.click '.auth-email-form__submit'
      page.click '.auth-signin-form__submit'
      page.expectText '.auth-form', 'Check your email'
      page.expectText '.auth-form', 'instantly log in'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.dashboard-page', 'Recent Threads'

    it 'can send login link to user with a password', ->
      page.loadPath 'setup_dashboard_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.click '.auth-signin-form__login-link'
      page.expectText '.auth-form', 'Check your email'
      page.expectText '.auth-form', 'instantly log in'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.dashboard-page', 'Recent Threads'

    it 'can set a password', ->
      page.loadPath 'setup_dashboard_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'jennifer_grey@example.com'
      page.click '.auth-email-form__submit'
      page.click '.auth-signin-form__set-password'
      page.expectText '.auth-form', 'Check your email'
      page.expectText '.auth-form', 'set your password'

    it 'can sign up a user', ->
      page.loadPath 'setup_dashboard_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'max_von_sydow@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signup-form__name input', 'Max Von Sydow'
      page.click '.auth-signup-form__submit'
      page.expectText '.auth-form', 'Check your email'
      page.expectText '.auth-form', 'instantly log in'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.dashboard-page', 'Recent Threads'

    it 'does not log in when password is incorrect', ->
      page.loadPath 'visit_explore_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'w0rstmovie'
      page.click '.auth-signin-form__submit'
      page.expectText '.auth-form', 'that password is incorrect'
