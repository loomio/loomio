describe 'Profile', ->

  profileHelper = require './helpers/profile_helper.coffee'
  threadHelper = require './helpers/thread_helper.coffee'

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
    it 'can display a user and his/her groups', ->
      profileHelper.visitUserPage('jennifergrey')
      expect(profileHelper.nameText()).toContain('Jennifer Grey')
      expect(profileHelper.usernameText()).toContain('@jennifergrey')
      expect(profileHelper.groupsText()).toContain('Dirty Dancing Shoes')
