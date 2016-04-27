describe 'Transitioning beta users', ->

  page = require './helpers/page_helper.coffee'
  staticPage = require './helpers/static_page_helper.coffee'

  describe 'logged in', ->
    it 'shows a welcome modal upon returning', ->
      page.loadPath 'setup_non_angular_logged_in_user'
      page.expectText '.angular-welcome-modal', 'Welcome to the new Loomio'

  describe 'logged out', ->
    it 'shows a welcome modal on sign in', ->
      staticPage.loadPath 'setup_non_angular_login'
      staticPage.fillIn '#user_email', 'patrick_swayze@example.com'
      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'
      page.expectText '.angular-welcome-modal', 'Welcome to the new Loomio'
