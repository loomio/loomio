describe 'Previous proposals', ->

  page = require './helpers/page_helper.coffee'

  beforeEach ->
    page.loadPath('setup_previous_proposal')

  describe 'previous proposals page', ->
    it 'displays proposal previews for each closed proposal', ->
      page.expectText('.proposal-collapsed__title', 'lets go hiking to the moon')
