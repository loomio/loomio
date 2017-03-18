describe 'Invitations', ->
  page = require './helpers/page_helper.coffee'
  staticPage = require './helpers/static_page_helper.coffee'

  it 'sends default invitations to a couple of people', ->
    page.loadPath 'setup_new_group'
    page.click '.members-card__invite-members-btn'
    page.fillIn '.invitation-form__email-addresses', 'Sam My <sammy@example.com>, pammy@example.com'
    page.click '.invitation-form__submit'
    page.expectFlash '2 invitations sent.'

  it 'disables send button when no valid email addresses present', ->
    page.loadPath 'setup_new_group'
    page.click '.members-card__invite-members-btn'
    page.fillIn '.invitation-form__email-addresses', 'invalidemailaddress'
    page.expectDisabledElement '.invitation-form__submit'

  it 'allows entering email addresses to send invitations to', ->
    page.loadPath 'setup_new_group'
    page.click '.members-card__invite-members-btn'
    page.fillIn '.invitation-form__email-addresses', 'dilly@example.com'
    page.click '.invitation-form__submit'
    page.expectFlash 'Invitation sent.'

  it 'has invitation link to share with the team', ->
    page.loadPath 'setup_new_group'
    page.click '.members-card__invite-members-btn'
    page.expectInputValue '.invitation-form__shareable-link-field', '/invitations/'

  it 'displays an error if all invitees are existing group members', ->
    page.loadPath 'setup_new_group'
    page.click '.members-card__invite-members-btn'
    page.fillIn '.invitation-form__email-addresses', 'patrick_swayze@example.com'
    page.click '.invitation-form__submit'
    page.expectText '.invitation-form__validation-errors', "We didn't send invitations to the email addresses provided because they belong to people already in the group."

  it 'lets you add members from the parent to a subgroup', ->
    page.loadPath 'setup_group'
    page.click '.group-page-actions__button',
               '.group-page-actions__add-subgroup-link'

    page.fillIn '#group-name', 'subgroup for some'

    page.click '.group-form__submit-button',
               '.members-card__invite-members-btn',
               '.invitation-form__add-members',
               '.add-members-modal__list-item:first-of-type',
               '.add-members-modal__submit'

    page.expectFlash 'Emilio Estevez added to Subgroup'

  it 'preselects current group if form launched from start menu while viewing group or thread page', ->
    page.loadPath 'setup_dashboard'
    page.clickFirst '.thread-preview__link'
    page.click '.start-menu__start-button'
    page.click '.start-menu__invitePeople'
    page.expectText '.invitation-form__group-select', 'Dirty Dancing Shoes'

  xit 'allows sign in for invitations with existing email addresses', ->
    staticPage.loadPath 'setup_existing_user_invitation'
    staticPage.click 'a[href]'

    staticPage.expectText 'h1', 'Dirty Dancing Shoes'
    staticPage.fillIn '#user_password', 'gh0stmovie'
    staticPage.click '#sign-in-btn'
    page.expectText '.group-theme__name', 'Dirty Dancing Shoes'
    page.expectText '.members-card__list', 'JN'

  xit 'allows sign up for invitations with new email addresses', ->
    staticPage.loadPath 'setup_new_user_invitation'
    staticPage.click 'a[href]'

    staticPage.expectText 'h1', 'Dirty Dancing Shoes'
    staticPage.fillIn '#user_name', 'Judd Nelson'
    staticPage.fillIn '#user_password', 'gh0stmovie'
    staticPage.fillIn '#user_password_confirmation', 'gh0stmovie'
    staticPage.click '#create-account'

    page.expectText '.group-theme__name', 'Dirty Dancing Shoes'
    page.expectText '.members-card__list', 'JN'

  xit 'allows sign up for team invitation link', ->
    staticPage.ignoreSynchronization ->
      staticPage.loadPath 'setup_team_invitation_link'

      staticPage.fillIn '#user_name', 'Judd Nelson'
      staticPage.fillIn '#user_email', 'judd@example.com'
      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.fillIn '#user_password_confirmation', 'gh0stmovie'
      staticPage.click '#create-account'

      page.expectText '.group-theme__name', 'Dirty Dancing Shoes'
      page.expectText '.members-card__list', 'JN'

  xit 'takes the user to the group if they\'ve already accepted', ->
    staticPage.ignoreSynchronization ->
      staticPage.loadPath 'setup_used_invitation'

      staticPage.click 'a[href]'

      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'

      page.expectText '.group-theme__name', 'Dirty Dancing Shoes'
      page.expectText '.members-card__list', 'JN'

  xit 'displays an error if logging in as a different user', ->
    staticPage.ignoreSynchronization ->
      staticPage.loadPath 'setup_used_invitation'

      staticPage.click 'a[href]'

      staticPage.fillIn '#user_email', 'emilio@loomio.org'
      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'

      staticPage.expectText 'body.invitations', 'This invitation has already been used'

  xit 'displays an error if the invitation has been cancelled', ->
    staticPage.ignoreSynchronization ->
      staticPage.loadPath 'setup_cancelled_invitation'

      staticPage.click 'a[href]'

      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'

      staticPage.expectText 'body.invitations', 'This invitation has been cancelled'
