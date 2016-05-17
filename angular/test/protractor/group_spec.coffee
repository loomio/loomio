describe 'Group Page', ->

  page = require './helpers/page_helper.coffee'
  staticPage = require './helpers/static_page_helper.coffee'

  describe 'start group from home page', ->
    it 'allows starting a group via the start_group route', ->
      staticPage.loadPath 'view_homepage_as_visitor'
      staticPage.click '#try-it-main'
      staticPage.fillIn '#group_name', 'My First Group'
      staticPage.fillIn '#group_description', 'Building a Better Bolshevik'
      staticPage.fillIn '#name', 'Test Example'
      staticPage.fillIn '#email', 'test@example.com'
      staticPage.click '#sign-up-submit'

      staticPage.loadPath 'last_email'
      staticPage.click 'a[href]'

      staticPage.fillIn '#user_password', 'vivalarevolucion'
      staticPage.fillIn '#user_password_confirmation', 'vivalarevolucion'
      staticPage.click  '#create-account'

      page.expectText '.modal-title', 'Welcome to your new group'
      page.click '.group-welcome-modal__close-button'
      page.expectText '.group-theme__name', 'My First Group'
      page.expectFlash 'Welcome! You have signed up successfully'

    it 'allows starting a group with an existing email', ->
      staticPage.loadPath 'view_homepage_as_visitor'
      staticPage.click '#try-it-main'
      staticPage.fillIn '#group_name', 'My First Group'
      staticPage.fillIn '#group_description', 'Building a Better Bolshevik'
      staticPage.fillIn '#name', 'Test Example'
      staticPage.fillIn '#email', 'patrick_swayze@example.com'
      staticPage.click '#sign-up-submit'

      staticPage.loadPath 'last_email'
      staticPage.click 'a[href]'

      staticPage.fillIn '#user_password', 'gh0stmovie'
      staticPage.click '#sign-in-btn'

      page.expectText '.modal-title', 'Welcome to your new group'
      page.click '.group-welcome-modal__close-button'
      page.expectText '.group-theme__name', 'My First Group'
      page.expectFlash 'Signed in successfully'

  describe 'non-member views group', ->
    describe 'logged out user', ->
      it 'should allow you to join an open group', ->
        page.loadPath 'view_open_group_as_visitor'
        page.click '.join-group-button__join-group'
        staticPage.fillIn '#user_name', 'Name'
        staticPage.fillIn '#user_email', 'test@example.com'
        staticPage.fillIn '#user_password', 'complex_password'
        staticPage.fillIn '#user_password_confirmation', 'complex_password'
        staticPage.click '#create-account'
        page.expectElement '.lmo-navbar__item--user'
        page.expectElement '.group-theme__name', 'Open Dirty Dancing Shoes'

      it 'should allow you to request to join a closed group', ->
        page.loadPath 'view_closed_group_as_visitor'
        page.click '.join-group-button__ask-to-join-group'
        page.fillIn '#membership-request-name', 'Chevy Chase'
        page.fillIn '#membership-request-email', 'chevychase@example.com'
        page.click '.membership-request-form__submit-btn'
        page.expectFlash 'You have requested membership to Closed Dirty Dancing Shoes'

      it 'should reload a closed group after logging in', ->
        page.loadPath 'view_closed_group_as_visitor'
        page.click '.lmo-navbar__sign-in'
        page.fillIn '#user-email', 'jennifer_grey@example.com'
        page.fillIn '#user-password', 'gh0stmovie'
        page.click '.sign-in-form__submit-button'
        page.expectText '.group-theme__name', 'Closed Dirty Dancing Shoes'
        page.expectText '.thread-previews-container', 'This thread is private'
        page.expectElement '.navbar-user-options__user-profile-icon'

      it 'should prompt for login for secret group', ->
        page.loadPath 'view_secret_group_as_visitor'
        page.fillIn '#user-email', 'patrick_swayze@example.com'
        page.fillIn '#user-password', 'gh0stmovie'
        page.click '.sign-in-form__submit-button'
        page.expectText '.group-theme__name', 'Secret Dirty Dancing Shoes'
        page.expectElement '.navbar-user-options__user-profile-icon'

      it 'does not allow mark as read or mute', ->
        page.loadPath('view_open_group_as_visitor')
        page.expectNoElement('.thread-preview__mark-as-read')
        page.expectNoElement('.thread-preview__mute')

      it 'open group displays previous proposals', ->
        page.loadPath('view_open_group_as_visitor')
        page.expectText('.group-previous-proposals-card', 'Let\'s go to the moon!')

    describe 'see joining option for each privacy type', ->
      it 'secret group', ->
        page.loadPath('view_secret_group_as_non_member')
        page.expectElement('.error-page')

      it 'closed group', ->
        page.loadPath('view_closed_group_as_non_member')
        page.expectElement('.join-group-button__ask-to-join-group')

      it 'open group', ->
        page.loadPath('view_open_group_as_non_member')
        page.expectElement('.join-group-button__join-group')

  describe 'starting a group', ->

    it 'redirects to dashboard and opens modal for logged in user with angular enabled', ->
      page.loadPath('setup_new_group')
      browser.get('start_group')
      page.expectText '.group-form', 'Start a group'

    it 'starts an open group', ->
      page.loadPath('setup_new_group')
      page.click '.group-welcome-modal__close-button',
                 '.start-menu__start-button',
                 '.start-menu__startGroup',
                 '.group-form__privacy-open',
                 '.group-form__advanced-link'

      # expect advanced to include "How do people join?"
      page.expectElement '.group-form__joining'
      page.expectNoElement '.group-form__allow-public-threads'

      page.fillIn '#group-name', 'Open please'
      page.click '.group-form__submit-button'
      page.click '.group-welcome-modal__close-button'
      page.expectText '.group-privacy-button', 'Open'

    it 'does not reshow the welcome modal', ->
      page.loadPath('setup_new_group')
      page.expectElement '.group-welcome-modal'
      browser.refresh()
      page.expectNoElement '.group-welcome-modal'

    it 'starts a closed group', ->
      page.loadPath('setup_new_group')
      page.click '.group-welcome-modal__close-button',
                 '.start-menu__start-button',
                 '.start-menu__startGroup',
                 '.group-form__privacy-closed',
                 '.group-form__advanced-link'

      page.expectNoElement '.group-form__joining'
      page.expectElement '.group-form__allow-public-threads'

      page.fillIn '#group-name', 'Closed please'
      page.click '.group-form__submit-button'
      page.click '.group-welcome-modal__close-button'
      page.expectText '.group-privacy-button', 'Closed'

    it 'starts a secret group', ->
      page.loadPath('setup_new_group')
      page.click '.group-welcome-modal__close-button',
                 '.start-menu__start-button',
                 '.start-menu__startGroup',
                 '.group-form__privacy-secret',
                 '.group-form__advanced-link'

      page.expectNoElement '.group-form__joining'
      page.expectNoElement '.group-form__allow-public-threads'

      page.fillIn '#group-name', 'Secret please'
      page.click '.group-form__submit-button'
      page.click '.group-welcome-modal__close-button'
      page.expectText '.group-privacy-button', 'Secret'


    it 'shows the welcome modal once per session', ->
      page.loadPath('setup_new_group')
      page.expectElement('.group-welcome-modal')
      page.click('.group-welcome-modal__close-button',
                 '.members-card__manage-members',
                 '.group-theme__name')
      page.expectNoElement('.group-welcome-modal')

  describe 'starting a subgroup', ->
    describe 'with a public parent', ->
      beforeEach ->
        page.loadPath('setup_open_group')
        page.click('.group-page-actions__button',
                   '.group-page-actions__add-subgroup-link')
        page.click '.group-form__advanced-link'

      it 'open subgroup', ->
        page.click '.group-form__privacy-open'
        page.expectElement '.group-form__joining'
        page.expectNoElement '.group-form__allow-public-threads'
        page.expectNoElement '.group-form__parent-members-can-see-discussions'

      it 'closed subgroup', ->
        page.click '.group-form__privacy-closed'
        page.expectNoElement '.group-form__joining'
        page.expectElement '.group-form__parent-members-can-see-discussions'
        page.expectElement '.group-form__allow-public-threads'

      it 'secret subgroup', ->
        page.click '.group-form__privacy-secret'
        page.expectNoElement '.group-form__joining'
        page.expectNoElement '.group-form__parent-members-can-see-discussions'
        page.expectNoElement '.group-form__allow-public-threads'

    describe 'with a closed parent', ->
      beforeEach ->
        page.loadPath('setup_closed_group')
        page.click('.group-page-actions__button',
                   '.group-page-actions__add-subgroup-link')
        page.click '.group-form__advanced-link'

      it 'open subgroup', ->
        page.click '.group-form__privacy-open'
        page.expectElement '.group-form__joining'
        page.expectNoElement '.group-form__allow-public-threads'
        page.expectNoElement '.group-form__parent-members-can-see-discussions'

      it 'closed subgroup', ->
        page.click '.group-form__privacy-closed'
        page.expectNoElement '.group-form__joining'
        page.expectElement '.group-form__parent-members-can-see-discussions'
        page.expectElement '.group-form__allow-public-threads'

      it 'secret subgroup', ->
        page.click '.group-form__privacy-secret'
        page.expectNoElement '.group-form__joining'
        page.expectNoElement '.group-form__parent-members-can-see-discussions'
        page.expectNoElement '.group-form__allow-public-threads'

    describe 'with a secret parent', ->
      beforeEach ->
        page.loadPath('setup_secret_group')
        page.click('.group-page-actions__button',
                   '.group-page-actions__add-subgroup-link')
        page.click '.group-form__advanced-link'

      it 'open subgroup', ->
        page.expectNoElement '.group-form__privacy-open'

      it 'closed subgroup', ->
        page.click '.group-form__privacy-closed'
        page.expectText '.group-form__privacy', 'members of Secret Dirty Dancing Shoes can find this subgroup and ask to join. All threads are private. Only members can see who is in the group.'
        page.expectNoElement '.group-form__joining'
        page.expectElement '.group-form__parent-members-can-see-discussions'
        page.expectNoElement '.group-form__allow-public-threads'

      it 'secret subgroup', ->
        page.click '.group-form__privacy-secret'
        page.expectNoElement '.group-form__joining'
        page.expectNoElement '.group-form__parent-members-can-see-discussions'
        page.expectNoElement '.group-form__allow-public-threads'

    # it 'successfully starts a subgroup', ->
    #   page.click('.group-page-actions__button',
    #              '.group-page-actions__add-subgroup-link')
    #   page.fillIn('#group-name', 'The Breakfast Club')
    #   page.click('.group-form__submit-button')
    #   page.expectText('.group-theme__name', 'Dirty Dancing Shoes')
    #   page.expectText('.group-theme__name', 'The Breakfast Club')

  describe 'editing group settings', ->
    beforeEach ->
      page.loadPath('setup_group')
      page.click('.group-page-actions__button',
                 '.group-page-actions__edit-group-link')

    it 'successfully edits group name and description', ->
      page.fillIn('#group-name', 'Clean Dancing Shoes')
      page.fillIn('#group-description', 'Dusty sandles')
      page.click('.group-form__submit-button')
      page.expectFlash('Group updated')
      page.expectText('.group-theme__name', 'Clean Dancing Shoes')
      page.expectText('.group-page__description-text', 'Dusty sandles')

    it 'displays a validation error when name is blank', ->
      page.fillIn('#group-name', '')
      page.click('.group-form__submit-button')
      page.expectText('.lmo-validation-error', "can't be blank")

    it 'can be a very open group', ->
      page.click('.group-form__advanced-link')

      selectThese = ['.group-form__privacy-open',
                      '.group-form__membership-granted-upon-request',
                      '.group-form__members-can-create-subgroups']

      expectThese = ['.group-form__privacy-open',
                      '.group-form__membership-granted-upon-request',
                      '.group-form__members-can-add-members',
                      '.group-form__members-can-create-subgroups']

      page.click(selectThese)
      page.click('.group-form__submit-button')

      # confirm privacy change
      page.acceptConfirmDialog()

      # reopen form
      page.click('.group-page-actions__button',
                 '.group-page-actions__edit-group-link',
                 '.group-form__advanced-link')

      # confirm the settings have stuck
      page.expectSelected(expectThese)

    it 'can be a very locked down group', ->
      page.click('.group-form__advanced-link',
                 '.group-form__privacy-secret')

      options = ['.group-form__members-can-start-discussions',
                 '.group-form__members-can-edit-discussions',
                 '.group-form__members-can-edit-comments',
                 '.group-form__members-can-raise-motions',
                 '.group-form__members-can-vote']

      page.click(options)
      page.click('.group-form__submit-button')

      # confirm privacy change
      page.acceptConfirmDialog()

      # reopen form
      page.click('.group-page-actions__button',
                 '.group-page-actions__edit-group-link',
                 '.group-form__advanced-link')

      # confirm the settings have stuck
      page.expectSelected('.group-form__privacy-secret')
      page.expectNotSelected(options)

  describe 'leaving a group', ->
    it 'allows group members to leave the group', ->
      # leave group and expect the group has left groups page
      page.loadPath('setup_group_with_multiple_coordinators')
      page.click('.group-page-actions__button',
                 '.group-page-actions__leave-group',
                 '.leave-group-form__submit')
      page.expectFlash('You have left this group')
      # click 'groups' from nav
      page.click('.groups-item')
      page.expectNoText('.groups-page__groups', 'Dirty Dancing Shoes')

    it 'prevents last coordinator from leaving the group', ->
      # click leave group from the group actions downdown
      # see that we can't leave until we add a coordinator
      # click add coordinator and check we're taken to the memberships page
      page.loadPath('setup_group')
      page.click('.group-page-actions__button',
                 '.group-page-actions__leave-group')
      page.expectText('.leave-group-form', 'You cannot leave this group')
      page.click('.leave-group-form__add-coordinator')
      page.expectElement('.memberships-page__memberships h2')

  describe 'archiving a group', ->

    it 'allows a coordinator to archive a group', ->
      page.loadPath('setup_group')
      page.click('.group-page-actions__button',
                 '.group-page-actions__archive-group',
                 '.archive-group-form__submit')
      page.expectFlash('This group has been deactivated')
      page.click('.groups-item')
      page.expectNoText('.groups-page__groups', 'Dirty Dancing Shoes')

  describe 'handling drafts', ->
    it 'handles empty draft privacy gracefully', ->
      page.loadPath 'setup_group_with_empty_draft'
      page.click '.group-welcome-modal__close-button',
                 '.discussions-card__new-thread-button'
      page.expectText('.privacy-notice', 'The thread will only be visible')

  describe 'starting a discussion', ->
    beforeEach ->
      page.loadPath('setup_group')

    it 'successfully starts a discussion', ->
      page.click('.discussions-card__new-thread-button')
      page.fillIn('#discussion-title', 'Nobody puts baby in a corner')
      page.fillIn('#discussion-context', "I've had the time of my life")
      page.click('.discussion-form__submit')
      page.expectFlash('Thread started')
      page.expectText('.thread-context', 'Nobody puts baby in a corner' )
      page.expectText('.thread-context', "I've had the time of my life" )

    it 'automatically saves drafts', ->
      page.click('.discussions-card__new-thread-button')
      page.fillIn('#discussion-title', 'Nobody puts baby in a corner')
      page.fillIn('#discussion-context', "I've had the time of my life")
      page.click('.discussion-form__cancel')
      page.click('.discussions-card__new-thread-button')
      page.expectInputValue('#discussion-title', 'Nobody puts baby in a corner' )
      page.expectInputValue('#discussion-context', "I've had the time of my life" )

  describe 'changing membership email settings', ->
    beforeEach ->
      page.loadPath('setup_group')

    it 'lets you change membership volume', ->
      page.click '.group-page-actions__button',
                 '.group-page-actions__change-volume-link',
                 '#volume-normal',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed about new threads and proposals in this group.'

    it 'lets you change the membership volume for all memberships', ->
      page.click '.group-page-actions__button',
                 '.group-page-actions__change-volume-link',
                 '#volume-normal',
                 '.change-volume-form__apply-to-all',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed about new threads and proposals in all your groups.'

  describe 'subdomains', ->
    it 'handles subdomain redirects', ->
      page.loadPath 'setup_group_with_subdomain'
      page.expectText '.group-theme__name', 'Ghostbusters'
