describe 'Profile', ->

  profileHelper = require './helpers/profile_helper.coffee'
  threadHelper = require './helpers/thread_helper.coffee'
  page = require './helpers/page_helper.coffee'
  staticPage = require './helpers/static_page_helper.coffee'

  beforeEach ->
    threadHelper.load()

  describe 'updating a profile name', ->
    it 'successfully updates a profile', ->
      page.click '.sidebar__list-item-button--profile'
      profileHelper.updateProfile('Ferris Bueller', 'ferrisbueller', 'ferris@loomio.org')
      expect(profileHelper.nameInput().getAttribute('value')).toContain('Ferris Bueller')
      expect(profileHelper.usernameInput().getAttribute('value')).toContain('ferrisbueller')
      expect(profileHelper.emailInput().getAttribute('value')).toContain('ferris@loomio.org')

  describe 'visiting a user profile', ->
    it 'displays a user and their non-secret groups', ->
      profileHelper.visitUserPage('jennifergrey')
      expect(profileHelper.nameText()).toContain('Jennifer Grey')
      expect(profileHelper.usernameText()).toContain('@jennifergrey')
      expect(profileHelper.groupsText()).toContain('Dirty Dancing Shoes')

    it 'displays secret groups to other members', ->
      page.loadPath('setup_profile_with_group_visible_to_members')
      page.expectText('.user-page__profile', 'Secret Dirty Dancing Shoes')

    it 'does not display secret groups to visitors', ->
      page.loadPath('setup_restricted_profile')
      page.expectNoText('.user-page__profile', 'Secret Dirty Dancing Shoes')

  describe 'deactivating an account', ->

    describe 'as the sole coordinator of a group', ->
      it 'successfully deactivates the account', ->
        page.click '.sidebar__list-item-button--profile'
        page.click '.profile-page__deactivate'
        page.expectText '.deactivation-modal', 'When you deactivate your account:'
        page.click '.deactivation-modal__confirm'
        browser.driver.sleep(100)
        page.expectText '.only-coordinator-modal', 'A group must have at least one coordinator. You are the only coordinator of the following groups:'

    describe 'as one of several coordinators of a group', ->
      xit 'prevents you from deactivating the account', ->
        page.loadPath 'setup_group_with_multiple_coordinators'
        page.click '.sidebar__list-item-button--profile'
        page.click '.profile-page__deactivate'
        page.click '.deactivation-modal__confirm'
        page.click '.lmo-btn--danger'
        browser.sleep(1000)
        staticPage.expectFlash 'There is a deactivated account associated with this email address'
