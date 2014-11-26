describe 'DiscussionModel', ->
  discussionModel = null
  discussion = null
  author = null

  beforeEach module 'loomioApp'

  beforeEach ->
    inject (DiscussionModel, UserModel) ->
      discussionModel = DiscussionModel
      discussion = new DiscussionModel(id: 1, title: 'Hi')
      author = new UserModel(id: 1, name: 'Sam')

  describe 'author()', ->
    it 'returns the discussion author', ->
      discussion.authorId = author.primaryId
      expect(discussion.author()).toBe(author)
