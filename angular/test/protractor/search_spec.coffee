describe 'Search', ->

  page = require './helpers/page_helper.coffee'

  describe 'searching for a thread', ->
    beforeEach ->
      page.loadPath('setup_discussion')

    it 'searches for and loads a thread by title', ->
      page.click('.sidebar__list-item-button--recent')
      page.fillIn('.navbar-search__input', 'what star')
      page.click('.navbar-search__results a.selector-list-item-link')
      page.expectText('.context-panel', "What star sign are you?")
