describe 'ProposalModel', ->
  modelClass = null
  modelInstance = null

  beforeEach module 'loomioApp'

  vote2001 = {createdAt: moment().year(2001), proposalId: 1}
  vote2002 = {createdAt: moment().year(2002), proposalId: 1}
  vote2003 = {createdAt: moment().year(2003), proposalId: 1}

  mockRecordStoreService =
    registerModel: ->
    get: -> [ vote2001, vote2003, vote2002 ]

  beforeEach ->
    module ($provide) ->
      $provide.value('RecordStoreService', mockRecordStoreService)
      return

    inject (ProposalModel) ->
      modelClass = ProposalModel

  describe 'lastVoteByUser', ->

    beforeEach ->
      modelInstance = new modelClass
      console.log(modelInstance)

    it 'returns the most recent vote by the user', ->
      expect(modelInstance.lastVoteByUser()).toBe(vote2003)


