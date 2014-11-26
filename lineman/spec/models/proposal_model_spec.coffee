#describe 'ProposalModel', ->
  #modelClass = null
  #modelInstance = null

  #beforeEach module 'loomioApp'

  #vote1 = {createdAt: "2001-10-28T02:29:05.822Z", proposalId: 1, authorId: 1}
  #vote2 = {createdAt: "2002-10-28T02:29:05.822Z", proposalId: 1, authorId: 1}
  #vote3 = {createdAt: "2003-10-28T02:29:05.822Z", proposalId: 1, authorId: 2}

  #user = {id: 1}

  #unsorted_votes = [vote1, vote3, vote2]

  #mockRecordStoreService =
    #registerModel: ->

  #beforeEach ->
    #module ($provide) ->
      #$provide.value('RecordStoreService', mockRecordStoreService)
      #return

    #inject (ProposalModel) ->
      #modelClass = ProposalModel

    #modelInstance = new modelClass
    #modelInstance.votes = -> unsorted_votes

  #describe 'isActive', ->
    #it 'is true when closedAt is falsy'
    #it 'is true when closedAt is truthy'

  #describe 'userHasVoted', ->
    #it 'is false when the user has not voted', ->
      #expect(modelInstance.userHasVoted({id: 3})).toBe(false)

    #it 'is true when the user has voted', ->
      #expect(modelInstance.userHasVoted({id: 2})).toBe(true)

  #describe 'lastVoteByUser', ->
    #it 'returns the most recent vote by the user', ->
      #expect(modelInstance.lastVoteByUser(user)).toBe(vote2)

  #describe 'uniqueVotes', ->
    #it 'only returns one vote per user', ->
      #expect(modelInstance.uniqueVotes().length).toEqual(2)




