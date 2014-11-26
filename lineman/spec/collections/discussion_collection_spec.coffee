describe 'DiscussionCollection', ->
  discussion = null
  otherdiscussion = null
  store = null
  discussionModel = null

  beforeEach ->
    module 'loomioApp'
    inject (DiscussionCollection, DiscussionModel) ->
      db = new loki('test.db')
      store = new DiscussionCollection(db)
      discussionModel = DiscussionModel

  describe 'get', ->
    beforeEach ->
      discussion = new discussionModel({id: 1, key: 'a'})
      otherdiscussion = new discussionModel({id: 2, key: 'b'})
      store.put discussion
      store.put otherdiscussion

    it 'returns a whole collection', ->
      expect(store.get()).toEqual([discussion, otherdiscussion])

    it 'looks up item by id', ->
      expect(store.get(1)).toEqual(discussion)

    it 'returns null if nothing found', ->
      expect(store.get(7)).toBe(null)

    it 'looks up item by key', ->
      expect(store.get('a')).toEqual(discussion)

    it 'looks up items by ids', ->
      expect(store.get([1, 2])).toContain(discussion, otherdiscussion)

    it 'looks up items by keys', ->
      expect(store.get(['a', 'b'])).toContain(discussion, otherdiscussion)

    #it 'looks up items by function', ->
      #expect(store.get( (discussion) -> discussion.id == 1 )).toEqual([discussion])

  describe 'remove', ->
    beforeEach ->
      discussion = new discussionModel({id: 1, key: 'a'})

    it 'removes the object from the store', ->
      store.put discussion
      expect(store.get(discussion.id)).toEqual(discussion)
      store.remove(discussion)
      expect(store.get(discussion.id)).toBe(null)
