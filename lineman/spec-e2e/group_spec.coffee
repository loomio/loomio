describe 'Group Page', ->

  page = require './helpers/page_helper.coffee'

  describe 'non-member views group', ->
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

    it 'shows the welcome modal once per session', ->
      page.loadPath('setup_new_group')
      page.expectElement('.group-welcome-modal')
      page.click('.group-welcome-modal__close-button',
                 '.members-card__manage-members',
                 '.group-theme__name')
      page.expectNoElement('.group-welcome-modal')

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
      groupsHelper.clickStartThreadButton()
      page.fillIn('#discussion-title', 'Nobody puts baby in a corner')
      page.fillIn('#discussion-context', "I've had the time of my life")
      page.click('.discussion-form__cancel')
      groupsHelper.clickStartThreadButton()
      page.expectText('#discussion-title', 'Nobody puts baby in a corner' )
      page.expectText('#discussion-context', "I've had the time of my life" )

  describe 'starting a subgroup', ->
    beforeEach ->
      page.loadPath('setup_group')

    it 'successfully starts a subgroup', ->
      page.click('.group-page-actions__button',
                 '.group-page-actions__add-subgroup-link')
      page.fillIn('#group-name', 'The Breakfast Club')
      page.click('.group-form__submit-button')
      page.expectText('.group-theme__name', 'Dirty Dancing Shoes')
      page.expectText('.group-theme__name', 'The Breakfast Club')

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

      options = ['.group-form__privacy-open',
                 '.group-form__membership-granted-upon-request',
                 '.group-form__members-can-add-members',
                 '.group-form__members-can-create-subgroups']

      page.click(options)
      page.click('.group-form__submit-button')

      # confirm privacy change
      page.acceptConfirmDialog()

      # reopen form
      page.click('.group-page-actions__button',
                 '.group-page-actions__edit-group-link',
                 '.group-form__advanced-link')

      # confirm the settings have stuck
      page.expectSelected(options)

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

  describe 'changing group volume', ->
    it 'lets you change group notification volume', ->
      page.loadPath('setup_group')
      page.expectText('.group-volume-card',
                      'You will be emailed about new threads and proposals in this group.')

      page.click('.group-volume-card__change-volume-link',
                 '#volume-loud',
                 '.change-volume-form__submit')

      page.expectText('.group-volume-card', 'Email everything')
