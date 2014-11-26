describe 'DiscussionCollection', ->
  discussion = null
  otherdiscussion = null
  collection = null
  discussionModel = null
  recordStore = null

  beforeEach ->
    module 'loomioApp'
    inject (RecordStore, DiscussionModel) ->
      discussionModel = DiscussionModel

      db = new loki('test.db')
      recordStore = new RecordStore(db)

      collection = recordStore.discussions

  describe 'get', ->
    beforeEach ->
      discussion = new discussionModel(recordStore, {id: 1, key: 'a'})
      otherdiscussion = new discussionModel(recordStore, {id: 2, key: 'b'})

    it 'returns a whole collection', ->
      expect(collection.get()).toContain(discussion, otherdiscussion)

    it 'looks up item by id', ->
      expect(collection.get(1)).toEqual(discussion)

    it 'returns null if nothing found', ->
      expect(collection.get(7)).toBeFalsy()

    it 'looks up item by key', ->
      expect(collection.get('a')).toEqual(discussion)

    it 'looks up items by ids', ->
      expect(collection.get([1, 2])).toContain(discussion, otherdiscussion)

    it 'looks up items by keys', ->
      expect(collection.get(['a', 'b'])).toContain(discussion, otherdiscussion)

    #it 'looks up items by function', ->
      #expect(collection.get( (discussion) -> discussion.id == 1 )).toEqual([discussion])

  describe 'remove', ->
    beforeEach ->
      discussion = new discussionModel(recordStore, {id: 1, key: 'a'})

    it 'removes the object from the collection', ->
      expect(collection.get(discussion.primaryId)).toEqual(discussion)
      collection.remove(discussion)
      expect(collection.get(discussion.primaryId)).toBeFalsy
