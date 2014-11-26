describe 'CommentCollection', ->
  store = null
  commentModel = null

  #beforeEach ->
    #module 'loomioApp'
    #inject (CommentStore, CommentModel) ->
      #commentModel = CommentModel
      #store = CommentStore

  #describe 'get', ->
    #beforeEach ->
      #comment = new CommentModel({id: 1, key: 'a'})
      #othercomment = new CommentModel({id: 2, key: 'b'})
      #service.put comment
      #service.put othercomment

    #it 'returns a whole collection', ->
      #expect(store.get()).toEqual([comment, othercomment])

    #it 'looks up item by id', ->
      #expect(store.get(1)).toEqual(comment)
