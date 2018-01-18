describe 'Group Page', ->

  page = require './helpers/page_helper.coffee'

  describe 'visiting a parent group as a subgroup member', ->
    it 'displays parent group in sidebar if member of a subgroup', ->
      page.loadPath 'visit_group_as_subgroup_member'
      page.expectText '.group-theme__name', 'Point Break'
      page.expectElement '.join-group-button__ask-to-join-group'
      page.click '.navbar__sidenav-toggle'
      page.expectElement '.sidebar__list-item--selected'

  describe 'non-member views group', ->
    describe 'logged out user', ->
      it 'should allow you to join an open group', ->
        page.loadPath 'view_open_group_as_visitor'
        page.click '.join-group-button__join-group'
        page.signInViaEmail('new@account.com')
        page.click '.join-group-button__join-group'
        page.expectElement '.sidebar__content'
        page.expectText '.group-theme__name', 'Open Dirty Dancing Shoes'

      it 'does not allow mark as read or mute', ->
        page.loadPath('view_open_group_as_visitor')
        page.expectNoElement('.thread-preview__dismiss')
        page.expectNoElement('.thread-preview__mute')

    describe 'signed in user', ->
      it 'join an open group', ->
        page.loadPath 'view_open_group_as_non_member'
        page.click '.join-group-button__join-group'
        page.sleep(1000) # you can sleep when you're dead
        page.expectFlash 'You are now a member'

      it 'request to join a closed group group', ->
        page.loadPath 'view_closed_group_as_non_member'
        page.click '.join-group-button__ask-to-join-group'
        page.fillIn '.membership-request-form__introduction', 'I have a reason'
        page.click '.membership-request-form__submit-btn'
        page.sleep(2000)
        page.expectFlash 'You have requested membership'

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

    describe 'on page load', ->
      it 'displays threads from subgroups in the discussions card', ->
        page.loadPath('setup_group_with_subgroups')
        page.expectText('.discussions-card__list', 'Vaya con dios')

  describe 'starting a group', ->

    it 'redirects to dashboard and opens modal for logged in user with angular enabled', ->
      page.loadPath('setup_new_group')
      browser.get('start_group')
      page.expectText '.start-group-page', 'Start a group'

    it 'starts an open group', ->
      page.loadPath('setup_new_group')
      page.click '.sidebar__list-item-button--start-group',
                 '.group-form__privacy-open',
                 '.group-form__advanced-link'

      # expect advanced to include "How do people join?"
      page.expectElement '.group-form__joining'
      page.expectNoElement '.group-form__allow-public-threads'

      page.fillIn '#group-name', 'Open please'
      page.click '.group-form__submit-button'
      page.expectText '.group-privacy-button', 'OPEN'

    it 'starts a closed group', ->
      page.loadPath('setup_new_group')
      page.click '.sidebar__list-item-button--start-group',
                 '.group-form__privacy-closed',
                 '.group-form__advanced-link'

      page.expectNoElement '.group-form__joining'
      page.expectElement '.group-form__allow-public-threads'

      page.fillIn '#group-name', 'Closed please'
      page.click '.group-form__submit-button'
      page.expectText '.group-privacy-button', 'CLOSED'

    it 'starts a secret group', ->
      page.loadPath('setup_new_group')
      page.click '.sidebar__list-item-button--start-group',
                 '.group-form__privacy-secret',
                 '.group-form__advanced-link'

      page.expectNoElement '.group-form__joining'
      page.expectNoElement '.group-form__allow-public-threads'

      page.fillIn '#group-name', 'Secret please'
      page.click '.group-form__submit-button'
      page.expectText '.group-privacy-button', 'SECRET'

  describe 'starting a subgroup', ->
    describe 'with a public parent', ->
      beforeEach ->
        page.loadPath('setup_open_group')
        page.click '.subgroups-card__start'
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
        page.click '.subgroups-card__start'
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
        page.click '.subgroups-card__start'
        page.click '.group-form__advanced-link'

      it 'open subgroup', ->
        page.expectNoElement '.group-form__privacy-open'

      it 'closed subgroup', ->
        page.click '.group-form__privacy-closed'
        page.expectText '.group-form__privacy', 'Members of Secret Dirty Dancing Shoes can find this subgroup and ask to join. All threads are private. Only members can see who is in the group.'
        page.expectNoElement '.group-form__joining'
        page.expectElement '.group-form__parent-members-can-see-discussions'
        page.expectNoElement '.group-form__allow-public-threads'

      it 'secret subgroup', ->
        page.click '.group-form__privacy-secret'
        page.expectNoElement '.group-form__joining'
        page.expectNoElement '.group-form__parent-members-can-see-discussions'
        page.expectNoElement '.group-form__allow-public-threads'

  describe 'editing group settings via group form', ->
    beforeEach ->
      page.loadPath('setup_group')
      page.click('.group-page-actions__button',
                 '.group-page-actions__edit-group-link')

    it 'successfully edits group name and description', ->
      page.fillIn('#group-name', 'Clean Dancing Shoes')
      page.fillIn('.group-form .lmo-textarea textarea', 'Dusty sandles')
      page.click('.group-form__submit-button')
      page.expectText('.group-theme__name', 'Clean Dancing Shoes')
      page.expectText('.description-card__text', 'Dusty sandles')

    xit 'displays a validation error when name is blank', ->
      page.fillIn('#group-name', '')
      page.click('.group-form__submit-button')
      page.sleep(500)
      page.expectText('.lmo-validation-error', "can't be blank")

    it 'can be a very open group', ->
      page.click '.group-form__advanced-link',
                 '.group-form__privacy-open',
                 '.group-form__membership-granted-upon-request',
                 '.group-form__members-can-create-subgroups',
                 '.group-form__submit-button'

      # confirm privacy change
      page.acceptConfirmDialog()

      # reopen form
      page.click '.group-page-actions__button',
                 '.group-page-actions__edit-group-link',
                 '.group-form__advanced-link'

      # confirm the settings have stuck
      page.expectElement '.group-form__privacy-open.md-checked'
      page.expectElement '.group-form__membership-granted-upon-request.md-checked'
      page.expectElement '.group-form__members-can-add-members .md-checked'
      page.expectElement '.group-form__members-can-create-subgroups .md-checked'

    it 'can be a very locked down group', ->
      page.click '.group-form__advanced-link',
                 '.group-form__privacy-secret',
                 '.group-form__members-can-start-discussions',
                 '.group-form__members-can-edit-discussions',
                 '.group-form__members-can-edit-comments',
                 '.group-form__members-can-raise-motions',
                 '.group-form__members-can-vote',
                 '.group-form__submit-button'

      # confirm privacy change
      page.acceptConfirmDialog()

      # reopen form
      page.click('.group-page-actions__button',
                 '.group-page-actions__edit-group-link',
                 '.group-form__advanced-link')

      # confirm the settings have stuck
      page.expectElement   '.group-form__privacy-secret.md-checked'
      page.expectNoElement '.group-form__members-can-start-discussions .md-checked'
      page.expectNoElement '.group-form__members-can-edit-discussions .md-checked'
      page.expectNoElement '.group-form__members-can-edit-comments .md-checked'
      page.expectNoElement '.group-form__members-can-raise-motions .md-checked'
      page.expectNoElement '.group-form__members-can-vote .md-checked'

  describe 'leaving a group', ->
    it 'allows group members to leave the group', ->
      # leave group and expect the group has left groups page
      page.loadPath('setup_group_with_multiple_coordinators')
      page.click('.group-page-actions__button',
                 '.group-page-actions__leave-group',
                 '.leave-group-form__submit')
      page.expectFlash('You have left this group')
      page.expectText('.dashboard-page__no-groups', "You don't have any recent threads because you are not a member of any groups.")

    it 'prevents last coordinator from leaving the group', ->
      # click leave group from the group actions downdown
      # see that we can't leave until we add a coordinator
      # click add coordinator and check we're taken to the memberships page
      page.loadPath('setup_group')
      page.click('.group-page-actions__button',
                 '.group-page-actions__leave-group')
      page.expectText('.leave-group-form', 'You cannot leave this group')

  describe 'archiving a group', ->

    it 'allows a coordinator to archive a group', ->
      page.loadPath('setup_group')
      page.click('.group-page-actions__button',
                 '.group-page-actions__archive-group',
                 '.archive-group-form__submit')
      page.expectFlash('This group has been deactivated')
      page.expectText('.dashboard-page__no-groups', "You don't have any recent threads because you are not a member of any groups.")

  describe 'handling drafts', ->
    it 'handles empty draft privacy gracefully', ->
      page.loadPath 'setup_group_with_empty_draft'
      page.click '.discussions-card__new-thread-button'
      page.expectText('.discussion-privacy-icon', 'The thread will only be visible')

  describe 'starting a discussion', ->
    beforeEach ->
      page.loadPath('setup_group')

    it 'successfully starts a discussion', ->
      page.click('.discussions-card__new-thread-button')
      page.fillIn('#discussion-title', 'Nobody puts baby in a corner')
      page.fillIn('.discussion-form textarea', "I've had the time of my life")
      page.click('.discussion-form__submit')
      page.expectFlash('Thread started')
      page.expectText('.context-panel', 'Nobody puts baby in a corner' )
      page.expectText('.context-panel', "I've had the time of my life" )

    it 'automatically saves drafts', ->
      page.click('.discussions-card__new-thread-button')
      page.fillIn('#discussion-title', 'Nobody puts baby in a corner')
      page.fillIn('.discussion-form textarea', "I've had the time of my life")
      page.click('.modal-cancel')
      page.click('.discussions-card__new-thread-button')
      page.expectInputValue('#discussion-title', 'Nobody puts baby in a corner' )
      page.expectInputValue('.discussion-form textarea', "I've had the time of my life" )

  describe 'changing membership email settings', ->
    beforeEach ->
      page.loadPath('setup_group')

    it 'lets you change membership volume', ->
      page.click '.group-page-actions__button',
                 '.group-page-actions__change-volume-link',
                 '#volume-loud',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed all activity in this group.'

    it 'lets you change the membership volume for all memberships', ->
      page.click '.group-page-actions__button',
                 '.group-page-actions__change-volume-link',
                 '#volume-loud',
                 '.change-volume-form__apply-to-all',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed all activity in all your groups.'

  describe 'subdomains', ->
    it 'handles subdomain redirects', ->
      page.loadPath 'setup_group_with_subdomain'
      page.expectText '.group-theme__name', 'Ghostbusters'

  describe 'group settings', ->
    it 'handles advanced group settings', ->
      page.loadPath 'setup_group_with_restrictive_settings'
      page.expectNoElement '.current-polls-card__start-poll'
      page.expectNoElement '.subgroups-card__start'
      page.expectNoElement '.discussions-card__new-thread-button'
      page.expectNoElement '.members-card__invite-members'
      page.click '.poll-common-preview'
      page.expectNoElement '.poll-common-vote-form__submit'
