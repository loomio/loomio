describe 'RecordStore', ->
  mockModel = null
  recordStore = null
  beforeEach module 'loomioApp'

  beforeEach ->
    db = new loki('test.db')
    inject (RecordStore, BaseModel) ->
      class MockModel extends BaseModel
        @singular: 'mock'
        @plural: 'mocks'

        initialize: (data) ->
          @id = data.id
          @key = data.key

      recordStore = new RecordStore(db)
      mockModel = MockModel

  it 'registers new collections', ->
    recordStore.addCollection(mockModel)
    expect(recordStore.mocks?).toBe(true)

  it 'imports records', ->
    recordStore.addCollection(mockModel)
    recordStore.import({mocks: [{id: 9, key:'z'}]})
    console.log recordStore.mocks.find()[0]
    expect(recordStore.mocks.get(9).key).toBe('z')
