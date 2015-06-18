describe 'Profile', ->

  profileHelper = require './helpers/profile_helper.coffee'
  threadHelper = require './helpers/thread_helper.coffee'

  beforeEach ->
    threadHelper.load()
    profileHelper.visitProfilePage()

  describe 'updating a profile name', ->

    it 'successfully updates a profile', ->
      profileHelper.updateProfile('Ferris Bueller', 'ferrisbueller', 'ferris@loomio.org')
      profileHelper.visitProfilePage()
      expect(profileHelper.nameInput().getAttribute('value')).toContain('Ferris Bueller')
      expect(profileHelper.usernameInput().getAttribute('value')).toContain('ferrisbueller')
      expect(profileHelper.emailInput().getAttribute('value')).toContain('ferris@loomio.org')
