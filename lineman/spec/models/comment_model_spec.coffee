describe 'CommentModel', ->
  discussionModel = null
  commentModel = null
  comment = null
  group = null
  recordStore = null
  author = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (RecordStore, CommentModel, UserModel, DiscussionModel, GroupModel) ->
      db = new loki('test.db')
      recordStore = new RecordStore(db)
      commentModel = CommentModel
      discussionModel = DiscussionModel
      group = new GroupModel(recordStore, {id: 1, name: 'group'})
      discussion = new DiscussionModel(recordStore, {id: 1, group_id: group.primaryId, title: 'discussion'})
      comment = new CommentModel(recordStore, {id: 1, title: 'Hi', discussion_id: discussion.primaryId})
      author = new UserModel(recordStore, {id:1, name: 'sam'})

  describe 'author()', ->
    it 'returns the comment author', ->
      comment.authorId = author.primaryId
      expect(comment.author()).toBe(author)

  describe 'isMostRecent', ->
    beforeEach ->
      discussion = new discussionModel(recordStore, id: 1)
      comment = new commentModel(recordStore, discussion_id: 1, created_at: "2000-01-01T00:00:00")

    it 'is true when no newer comments in the discussion', ->
      expect(comment.isMostRecent()).toBe(true)

    it 'is false when newer comments exist in the discussion', ->
      new commentModel(recordStore, discussion_id: 1, created_at: "2000-01-01T00:00:10")
      expect(comment.isMostRecent()).toBe(false)

  describe 'canBeEditedByAuthor', ->
    beforeEach ->
      comment = new commentModel(discussion_id: 1, created_at: "2000-01-01T00:00:00")

    describe 'group allows members to edit comments', ->
      it 'is true', ->
        group.membersCanEditComments = true
        expect(comment.canBeEditedByAuthor()).toBe(true)

    describe 'group disallows members to edit comments', ->
      beforeEach ->
        group.membersCanEditComments = false

      it 'is true when is most recent comment', ->
        expect(comment.canBeEditedByAuthor()).toBe(true)

      it 'is false when is is not most recent comment', ->
        mockRecordStoreService.get = ->
          [new commentModel(discussion_id: 1, created_at: "2000-01-01T00:00:10")]
        expect(comment.canBeEditedByAuthor()).toBe(false)


