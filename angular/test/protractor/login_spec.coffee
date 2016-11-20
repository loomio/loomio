describe 'Login', ->
  page       = require './helpers/page_helper.coffee'
  staticPage = require './helpers/static_page_helper.coffee'

  describe 'logging in as an existing user', ->
    it 'logs in in-app', ->
      page.loadPath 'view_open_group_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '#user-email', 'jennifer_grey@example.com'
      page.fillIn '#user-password', 'gh0stmovie'
      page.click '.sign-in-form__submit-button'
      page.waitForReload()
      page.expectElement '.sidebar__content'
      page.expectFlash 'Signed in successfully'

    it 'updates the locale on login', ->
      page.loadPath 'setup_spanish_user'
      page.click '.navbar__sign-in'
      page.fillIn '#user-email', 'patrick_swayze@example.com'
      page.fillIn '#user-password', 'gh0stmovie'
      page.click '.sign-in-form__submit-button'
      page.waitForReload()
      page.expectText '.explore-page', 'Explorar grupos en Loomio'

    it 'does not log in in-app when password is incorrect', ->
      page.loadPath 'view_open_group_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '#user-email', 'jennifer_grey@example.com'
      page.fillIn '#user-password', 'notapassword'
      page.click '.sign-in-form__submit-button'
      page.waitForReload()
      page.expectElement '.lmo-validation-error', 'Invalid email or password'

    it 'takes you to the explore page when not a member of any groups', ->
      staticPage.loadPath 'setup_login'
      staticPage.fillIn '#user_email', 'patrick_swayze@example.com'
      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'
      page.expectElement '.explore-page', 'Explore Loomio groups'

    it 'takes you to your group page when a member of one group', ->
      staticPage.loadPath 'setup_logged_out_group_member'
      staticPage.fillIn '#user_email', 'patrick_swayze@example.com'
      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'
      page.expectElement '.group-page', 'Dirty Dancing Shoes'

    it 'takes you to the dashboard when a member of multiple groups', ->
      staticPage.loadPath 'setup_logged_out_member_of_multiple_groups'
      staticPage.fillIn '#user_email', 'patrick_swayze@example.com'
      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'
      page.expectElement '.dashboard-page', 'Recent threads'

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
