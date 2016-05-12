describe 'Login', ->
  page       = require './helpers/page_helper.coffee'
  staticPage = require './helpers/static_page_helper.coffee'

  describe 'logging in as an existing user', ->
    it 'logs in in-app', ->
      page.loadPath 'view_open_group_as_visitor'
      page.click '.lmo-navbar__sign-in'
      page.fillIn '#user-email', 'jennifer_grey@example.com'
      page.fillIn '#user-password', 'gh0stmovie'
      page.click '.sign-in-form__submit-button'
      page.expectElement '.navbar-user-options__user-profile-icon'
      page.expectFlash 'Signed in successfully'

    it 'does not log in in-app when password is incorrect', ->
      page.loadPath 'view_open_group_as_visitor'
      page.click '.lmo-navbar__sign-in'
      page.fillIn '#user-email', 'jennifer_grey@example.com'
      page.fillIn '#user-password', 'notapassword'
      page.click '.sign-in-form__submit-button'
      page.expectElement '.lmo-validation-error', 'Invalid email or password'

    it 'logs in when password is correct', ->
      staticPage.loadPath 'setup_login'
      staticPage.fillIn '#user_email', 'patrick_swayze@example.com'
      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'
      page.expectText '.dashboard-page', 'Recent Threads'

    it 'does not log in when password is incorrect', ->
      staticPage.loadPath 'setup_login'
      staticPage.fillIn '#user_email', 'patrick_swayze@example.com'
      staticPage.fillIn '#user_password', 'w0rstmovie'
      staticPage.click '#sign-in-btn'
      staticPage.expectText '.alert-message', 'Invalid email or password'

  describe 'forgot password', ->
    it 'can reset a password', ->
      staticPage.loadPath 'setup_login'
      staticPage.click '#forgot-pwd'
      staticPage.fillIn '#user_email', 'patrick_swayze@example.com'
      staticPage.click 'input[type=submit]'
      staticPage.expectText '.alert-info', 'You will receive an email with instructions on how to reset your password'

      staticPage.loadPath 'last_email'
      staticPage.click 'a[href]'
      staticPage.fillIn '#user_password', 'drivinmeswayze'
      staticPage.fillIn '#user_password_confirmation', 'drivinmeswayze'
      staticPage.click 'input[type=submit]'

      page.expectFlash 'Your password has been changed successfully'
