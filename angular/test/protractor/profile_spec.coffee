describe 'Profile', ->

  profileHelper = require './helpers/profile_helper.coffee'
  threadHelper = require './helpers/thread_helper.coffee'
  page = require './helpers/page_helper.coffee'

  beforeEach ->
    threadHelper.load()

  describe 'updating a profile name', ->
    it 'successfully updates a profile', ->
      profileHelper.visitProfilePage()
      profileHelper.updateProfile('Ferris Bueller', 'ferrisbueller', 'ferris@loomio.org')
      profileHelper.visitProfilePage()
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
