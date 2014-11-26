describe 'DiscussionModel', ->
  discussionModel = null
  discussion = null
  author = null
  recordStore = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (RecordStore, DiscussionModel, UserModel) ->
      discussionModel = DiscussionModel
      db = new loki('test.db')
      recordStore = new RecordStore(db)
      discussion = new DiscussionModel(recordStore, {id: 1, title: 'Hi'})
      author = new UserModel(recordStore, {id: 1, name: 'Sam'})

  describe 'author()', ->
    it 'returns the discussion author', ->
      console.log author
      discussion.authorId = author.primaryId
      expect(discussion.author()).toBe(author)
