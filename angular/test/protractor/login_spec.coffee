describe 'Login', ->
  page       = require './helpers/page_helper.coffee'
  staticPage = require './helpers/static_page_helper.coffee'

  describe 'logging in as an existing user', ->
    fit 'logs in when password is correct', ->
      staticPage.loadPath 'setup_login'
      staticPage.fillIn '#user_email', 'patrick_swayze@example.com'
      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'
      page.expectText '.dashboard-page__heading', 'Recent Threads'

    fit 'does not log in when password is incorrect', ->
      staticPage.loadPath 'setup_login'
      staticPage.fillIn '#user_email', 'patrick_swayze@example.com'
      staticPage.fillIn '#user_password', 'w0rstmovie'
      staticPage.click '#sign-in-btn'
      staticPage.expectText '.alert-message', 'Invalid email or password'
