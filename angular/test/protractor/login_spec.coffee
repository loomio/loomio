describe 'Login', ->
  page = require './helpers/page_helper.coffee'

  describe 'via password', ->
    it 'does not log in when password is incorrect', ->
      page.loadPath 'setup_explore_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'w0rstmovie'
      page.click '.auth-signin-form__submit'
      page.expectText '.auth-form', 'that password doesn\'t match'

    it 'can login from the dashboard', ->
      page.loadPath 'setup_dashboard_as_visitor'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'gh0stmovie'
      page.click '.auth-signin-form__submit'
      page.waitForReload()
      page.expectFlash 'Signed in successfully'

    it 'can login from a closed group page', ->
      page.loadPath 'view_closed_group_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'gh0stmovie'
      page.click '.auth-signin-form__submit'
      page.waitForReload()
      page.expectFlash 'Signed in successfully'
      page.expectText '.group-theme__name', 'Closed Dirty Dancing Shoes'
      page.expectText '.thread-preview-collection__container', 'This thread is private'
      page.expectElement '.sidebar__content'

    it 'can login from a secret group page', ->
      page.loadPath 'view_secret_group_as_visitor'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'gh0stmovie'
      page.click '.auth-signin-form__submit'
      page.waitForReload()
      page.expectFlash 'Signed in successfully'
      page.expectText '.group-theme__name', 'Secret Dirty Dancing Shoes'
      page.expectElement '.sidebar__content'

    it 'can login from the explore page', ->
      page.loadPath 'setup_explore_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'gh0stmovie'
      page.click '.auth-signin-form__submit'
      page.waitForReload()
      page.expectFlash 'Signed in successfully'

    it 'can login from a discussion page', ->
      page.loadPath 'view_open_discussion_as_visitor'
      page.click '.comment-form__sign-in-btn'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'gh0stmovie'
      page.click '.auth-signin-form__submit'
      page.waitForReload()
      page.expectFlash 'Signed in successfully'
      page.fillIn '.comment-form textarea', 'I am new!'
      page.click '.comment-form__submit-button'
      page.expectFlash 'Comment added'

    it 'can accept an invitation', ->
      page.loadPath 'setup_invitation_to_user_with_password'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signin-form__password input', 'gh0stmovie'
      page.click '.auth-signin-form__submit'
      page.waitForReload()
      page.expectFlash 'Signed in successfully'
      page.expectText '.group-theme__name', 'Dirty Dancing Shoes'
      page.expectNoElement '.join-group-button'

  describe 'via link', ->
    it 'can send login link to user with a password', ->
      page.loadPath 'setup_dashboard_as_visitor'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.click '.auth-signin-form__login-link'
      page.expectText '.auth-form', 'Check your email'
      page.expectText '.auth-form', 'instantly log in'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.dashboard-page', 'Recent Threads'

    it 'can login from the dashboard', ->
      page.loadPath 'setup_dashboard_as_visitor'
      page.fillIn '.auth-email-form__email input', 'jennifer_grey@example.com'
      page.click '.auth-email-form__submit'
      page.click '.auth-signin-form__submit'
      page.expectText '.auth-form', 'Check your email'
      page.expectText '.auth-form', 'instantly log in'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.dashboard-page', 'Recent Threads'

    it 'can login from the explore page via link', ->
      page.loadPath 'setup_explore_as_visitor'
      page.click '.navbar__sign-in'
      page.fillIn '.auth-email-form__email input', 'jennifer_grey@example.com'
      page.click '.auth-email-form__submit'
      page.click '.auth-signin-form__submit'
      page.expectText '.auth-form', 'Check your email'
      page.expectText '.auth-form', 'instantly log in'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.explore-page', 'Explore groups'

    it 'can login from a discussion page', ->
      page.loadPath 'view_open_discussion_as_visitor'
      page.click '.comment-form__sign-in-btn'
      page.fillIn '.auth-email-form__email input', 'jennifer_grey@example.com'
      page.click '.auth-email-form__submit'
      page.click '.auth-signin-form__submit'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectElement '.comment-form__submit-button'

    it 'can accept an invitation', ->
      page.loadPath 'setup_invitation_to_user'
      page.click '.auth-email-form__submit'
      page.click '.auth-signin-form__submit'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.group-theme__name', 'Dirty Dancing Shoes'

  describe 'new account', ->
    it 'can sign up a user', ->
      page.loadPath 'setup_dashboard_as_visitor'
      page.fillIn '.auth-email-form__email input', 'max_von_sydow@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signup-form__name input', 'Max Von Sydow'
      page.click '.auth-signup-form__submit'
      page.expectText '.auth-form', 'Check your email'
      page.expectText '.auth-form', 'instantly log in'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.dashboard-page', 'Recent Threads'

    it 'can sign up a new user through the discussion page', ->
      page.loadPath 'view_open_discussion_as_visitor'
      page.click '.comment-form__sign-in-btn'
      page.fillIn '.auth-email-form__email input', 'max_von_sydow@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signup-form__name input', 'Max Von Sydow'
      page.click '.auth-signup-form__submit'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.context-panel__heading', 'I carried a watermelon'
      page.click '.comment-form__join-actions button'
      page.expectFlash 'You are now a member of Open Dirty Dancing Shoes'
      page.expectElement '.comment-form__submit-button'

    it 'can use a shareable link', ->
      page.loadPath 'view_closed_group_with_shareable_link'
      page.fillIn '.auth-email-form__email input', 'max_von_sydow@example.com'
      page.click '.auth-email-form__submit'
      page.fillIn '.auth-signup-form__name input', 'Max Von Sydow'
      page.click '.auth-signup-form__submit'
      page.expectText '.auth-form', 'Check your email'
      page.expectText '.auth-form', 'instantly log in'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.group-theme__name', 'Dirty Dancing Shoes'

    xit 'can log someone in from an invitation', ->
      page.loadPath 'setup_invitation_to_visitor'
      page.click '.auth-email-form__submit'
      page.expectText '.auth-form', 'Nice to meet you, Max Von Sydow'
      page.click '.auth-signup-form__submit'
      page.loadPath 'use_last_login_token'
      page.expectFlash 'Signed in successfully'
      page.expectText '.group-theme__name', 'Dirty Dancing Shoes'

  describe 'inactive account', ->
    xit 'prompts the user to contact us to reactivate', ->
      page.loadPath 'setup_deactivated_user'
      page.fillIn '.auth-email-form__email input', 'patrick_swayze@example.com'
      page.click '.auth-email-form__submit'
      page.expectText '.auth-inactive-form', 'has been deactivated!'
      page.click '.auth-inactive-form__submit'
      page.expectElement '.contact-form'
