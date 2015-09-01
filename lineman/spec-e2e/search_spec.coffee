describe 'Search', ->

  navbar = require './helpers/navbar.coffee'
  threadPage = require './helpers/thread_helper.coffee'

  describe 'searching for a thread', ->
    beforeEach ->
      threadPage.load()

    it 'searches for and loads a thread by title', ->
      navbar.clickRecent()
      navbar.enterSearchQuery('what star')
      navbar.clickFirstSearchResult()
      expect(threadPage.discussionTitle().getText()).toContain("What star sign are you?")
