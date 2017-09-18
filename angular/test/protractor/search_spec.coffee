describe 'Search', ->

  page = require './helpers/page_helper.coffee'

  describe 'searching for a thread', ->
    beforeEach ->
      page.loadPath('setup_discussion')

    it 'searches for and loads a thread by title', ->
      page.click      '.sidebar__list-item-button--decisions'
      page.click      '.navbar-search__button'
      page.fillIn     '.navbar-search__input input', 'what star'
      page.expectText '.md-autocomplete-suggestions-container', 'What star sign are you?'
