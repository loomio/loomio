describe 'Previous proposals', ->

  previousProposalsPage = require './helpers/previous_proposals_helper.coffee'

  beforeEach ->
    previousProposalsPage.load()

  describe 'previous proposals page', ->
    it 'displays proposal previews for each closed proposal', ->
      expect(previousProposalsPage.proposalTitle()).toContain('lets go hiking to the moon')
