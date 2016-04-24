describe 'Login', ->
  page       = require './helpers/page_helper.coffee'
  staticPage = require './helpers/static_page_helper.coffee'

  describe 'logging in as an existing user', ->
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
