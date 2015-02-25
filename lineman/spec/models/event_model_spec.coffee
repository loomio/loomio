describe 'EventModel', ->
  recordStore = null
  event = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records) ->
      recordStore = Records

    event = recordStore.events.initialize(id: 1, kind: 'comment_liked')

  #describe 'camelKind', ->
    #it 'returns a camelcased kind', ->
      #expect(event.camelKind()).toBe('commentLiked')

