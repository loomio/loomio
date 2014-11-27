describe 'CollectionWrapper', ->
  mock = null
  otherMock = null
  collection = null
  recordStore = null
  mockModel = null

  beforeEach ->
    module 'loomioApp'

    inject (RecordStore, CollectionWrapper, BaseModel) ->
      class MockModel extends BaseModel
        @singular: 'mock'
        @plural: 'mocks'

        initialize: (data) ->
          @id = data.id
          @key = data.key

      mockModel = MockModel
      db = new loki('test.db')
      recordStore = new RecordStore(db)
      collection = recordStore.addCollection(MockModel)


  describe 'new', ->
    it 'inserts new items into the collection', ->
      mock = collection.new({id:1})
      expect(collection.get(1)).toBe(mock)

    it 'updates existing items in the collection', ->
      mock = collection.new({id:1})
      collection.new({id:1, key: 'a'})
      expect(mock.key).toBe('a')
      expect(collection.find().length).toBe(1)

  describe 'get', ->
    beforeEach ->
      mock =  recordStore.mocks.new {id: 1, key: 'a'}
      othermock = recordStore.mocks.new {id: 2, key:'b'}

    it 'looks up item by id', ->
      expect(collection.get(1)).toEqual(mock)

    it 'returns null if nothing found for single', ->
      expect(collection.get(7)).toBe(null)

    it 'returns [] if nothing found for many', ->
      expect(collection.get([7]).length).toBe(0)

    it 'looks up item by key', ->
      expect(collection.get('a')).toEqual(mock)

    it 'looks up items by ids', ->
      expect(collection.get([1, 2])).toContain(mock, otherMock)

    it 'looks up items by keys', ->
      expect(collection.get(['a', 'b'])).toContain(mock, otherMock)

    #it 'looks up items by function', ->
      #expect(collection.get( (discussion) -> discussion.id == 1 )).toEqual([discussion])

  describe 'remove', ->
    beforeEach ->
      mock =  recordStore.mocks.new {id: 1, key: 'a'}

    it 'removes the object from the collection', ->
      expect(collection.get(mock.id)).toEqual(mock)
      collection.remove(mock)
      expect(collection.get(mock.id)).toBeFalsy
