describe 'CommentModel', ->
  commentModel = null
  comment = null
  group = {}

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (CommentModel) ->
      commentModel = CommentModel

  #describe 'canBeEditedByAuthor', ->
    #beforeEach ->
      #comment = new commentModel(discussion_id: 1, created_at: "2000-01-01T00:00:00")

    #describe 'group allows members to edit comments', ->
      #it 'is true', ->
        #group.membersCanEditComments = true
        #expect(comment.canBeEditedByAuthor()).toBe(true)

    #describe 'group disallows members to edit comments', ->
      #beforeEach ->
        #group.membersCanEditComments = false

      #it 'is true when is most recent comment', ->
        #expect(comment.canBeEditedByAuthor()).toBe(true)

      #it 'is false when is is not most recent comment', ->
        #mockRecordStoreService.get = ->
          #[new commentModel(discussion_id: 1, created_at: "2000-01-01T00:00:10")]
        #expect(comment.canBeEditedByAuthor()).toBe(false)

  #describe 'isMostRecent', ->
    #beforeEach ->
      #comment = new commentModel(discussion_id: 1, created_at: "2000-01-01T00:00:00")

    #it 'is true when no newer comments in the discussion', ->
      #mockRecordStoreService.get = -> []
      #expect(comment.isMostRecent()).toBe(true)

    #it 'is false when newer comments exist in the discussion', ->
      #mockRecordStoreService.get = ->
        #[new commentModel(discussion_id: 1, created_at: "2000-01-01T00:00:10")]
      #expect(comment.isMostRecent()).toBe(false)

