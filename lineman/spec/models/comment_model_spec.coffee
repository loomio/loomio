describe 'CommentModel', ->
  discussionModel = null
  commentModel = null
  comment = null
  discussion = null
  group = null
  recordStore = null
  author = null
  reply_comment = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (Records, DiscussionModel) ->
      recordStore = Records
      discussionModel = DiscussionModel
      group = recordStore.groups.initialize(id: 1, name: 'group')
      discussion = recordStore.discussions.initialize(id: 1, group_id: group.id, title: 'discussion')
      comment = recordStore.comments.initialize(id: 8, title: 'Hi', discussion_id: discussion.id, created_at: "2000-01-03T00:00:00")
      reply_comment = recordStore.comments.initialize(id: 9, parent_id: 8, title: 'Hello there', discussion_id: discussion.id, created_at: "2000-01-02T00:00:00")
      author = recordStore.users.initialize(id: 1, name: 'sam')

  describe 'parent', ->
    describe 'comment is a reply', ->
      it 'returns parent comment', ->
        expect(reply_comment.parent()).toBe(comment)

    describe 'comment is not a reply', ->
      it 'returns null', ->
        expect(comment.parent()).toBe(null)

  describe 'author()', ->
    it 'returns the comment author', ->
      comment.authorId = author.id
      expect(comment.author()).toBe(author)

  describe 'isMostRecent', ->
    it 'is true when no newer comments in the discussion', ->
      expect(comment.isMostRecent()).toBe(true)

    it 'is false when newer comments exist in the discussion', ->
      newComment = recordStore.comments.initialize(id: 6, discussion_id: 1, created_at: "2000-01-05T00:00:10")
      expect(comment.isMostRecent()).toBe(false)

  describe 'canBeEditedByAuthor', ->
    describe 'members Can Edit', ->
      it 'is true', ->
        group.membersCanEditComments = true
        expect(comment.canBeEditedByAuthor()).toBe(true)

    describe 'members Cannot edit', ->
      beforeEach ->
        group.membersCanEditComments = false

      it 'is true when is most recent comment', ->
        expect(comment.isMostRecent()).toBe(true)
        expect(comment.canBeEditedByAuthor()).toBe(true)

      it 'is false when is is not most recent comment', ->
        newComment = recordStore.comments.initialize(id: 9, discussion_id: 1, created_at: "2000-04-01T00:00:20")
        expect(comment.isMostRecent()).toBe(false)
        expect(comment.canBeEditedByAuthor()).toBe(false)


