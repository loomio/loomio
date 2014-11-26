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

    mock = new mockModel(recordStore, {id: 1, key: 'a'})
    othermock = new mockModel(recordStore, {id: 2, key:'b'})

  describe 'get', ->

    it 'returns a whole collection', ->
      expect(collection.get()).toContain(mock, otherMock)

    it 'looks up item by id', ->
      expect(collection.get(1)).toEqual(mock)

    it 'returns null if nothing found', ->
      expect(collection.get(7)).toBeFalsy()

    it 'looks up item by key', ->
      expect(collection.get('a')).toEqual(mock)

    it 'looks up items by ids', ->
      expect(collection.get([1, 2])).toContain(mock, otherMock)

    it 'looks up items by keys', ->
      expect(collection.get(['a', 'b'])).toContain(mock, otherMock)

    #it 'looks up items by function', ->
      #expect(collection.get( (discussion) -> discussion.id == 1 )).toEqual([discussion])

  describe 'remove', ->
    it 'removes the object from the collection', ->
      expect(collection.get(mock.id)).toEqual(mock)
      collection.remove(mock)
      expect(collection.get(mock.id)).toBeFalsy
