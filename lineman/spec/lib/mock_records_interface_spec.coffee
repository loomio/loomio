describe 'MockRecordsInterface', ->
  mock = null
  otherMock = null
  mockModel = null
  recordStore = null
  beforeEach module 'loomioApp'

  beforeEach ->
    inject (RecordStore, BaseModel, BaseRecordsInterface) ->
      class MockModel extends BaseModel
        @singular: 'mock'
        @plural: 'mocks'

        initialize: (data) ->
          @id = data.id
          @key = data.key

      class MockRecordsInterface extends BaseRecordsInterface
        model: MockModel
        plural: 'mocks'

      db = new loki('test.db')
      recordStore = new RecordStore(db)
      recordStore.addRecordsInterface(MockRecordsInterface)


  #describe 'fetchByGroup', ->
    #it 'uses restfulclient to get all discussions in the given group'

  #describe 'fetchByKey', ->
    #it 'uses restfulclient to request the discusssion'

  describe 'get', ->
    beforeEach ->
      mock =  {id: 1, key: 'a'}
      otherMock = {id: 2, key:'b'}
      recordStore.mocks.initialize(mock)
      recordStore.mocks.initialize(otherMock)

    it 'looks up item by id', ->
      expect(recordStore.mocks.find(1).id).toEqual(mock.id)

    it 'returns null if nothing found for single', ->
      expect(recordStore.mocks.find(7)).toBe(undefined)

    it 'returns [] if nothing found for many', ->
      expect(recordStore.mocks.find([7]).length).toBe(0)

    it 'looks up item by key', ->
      expect(recordStore.mocks.find('a').key).toEqual(mock.key)

    it 'looks up items by ids', ->
      expect(recordStore.mocks.find([1])[0].id).toBe(1)

    it 'looks up items by keys', ->
      expect(recordStore.mocks.find(['a'])[0].key).toBe('a')

    #it 'looks up items by function', ->
      #expect(collection.get( (discussion) -> discussion.id == 1 )).toEqual([discussion])
