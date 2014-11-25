describe 'DiscussionStore', ->
  store = null
  discussionModel = null

  beforeEach ->
    module 'loomioApp'
    inject (DiscussionStore, DiscussionModel) ->
      store = DiscussionStore

  describe 'get', ->
    beforeEach ->
      discussion = new discussionModel({id: 1, key: 'a'})
      otherdiscussion = new discussionModel({id: 2, key: 'b'})
      service.put discussion
      service.put otherdiscussion

    it 'returns a whole collection', ->
      expect(store.findAll()).toEqual([discussion, otherdiscussion])

    it 'looks up item by id', ->
      expect(store.get(1)).toEqual(discussion)

    it 'returns null if nothing found', ->
      expect(store.get(7)).toBe(undefined)

    it 'looks up item by key', ->
      expect(store.get('a')).toEqual(discussion)

    it 'looks up items by ids', ->
      expect(store.get([1, 2])).toEqual([discussion, otherdiscussion])

    it 'looks up items by keys', ->
      expect(store.get(['a', 'b'])).toEqual([discussion, otherdiscussion])

    #it 'looks up items by function', ->
      #expect(store.get( (discussion) -> discussion.id == 1 )).toEqual([discussion])

  describe 'remove', ->
    beforeEach ->
      discussion = new discussionModel({id: 1, key: 'a'})

    it 'removes the object from the store', ->
      store.put thing
      expect(store.get(thing.id)).toEqual(thing)
      service.remove(thing)
      expect(store.get(thing.id)).toBe(undefined)
