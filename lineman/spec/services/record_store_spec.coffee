describe 'RecordStore', ->
  mockModel = null
  recordStore = null
  beforeEach module 'loomioApp'

  beforeEach ->
    db = new loki('test.db')
    inject (RecordStore, BaseModel, BaseRecordsInterface) ->
      class MockModel extends BaseModel
        @singular: 'mock'
        @plural: 'mocks'

        initialize: (data) ->
          @id = data.id
          @key = data.key

      class MockRecordsInterface extends BaseRecordsInterface
        model: MockModel

      recordStore = new RecordStore(db)
      recordStore.addRecordsInterface(MockRecordsInterface)

  it 'adds record interfaces correctly', ->
    expect(recordStore.mocks?).toBe(true)

  it 'imports records', ->
    recordStore.import({mocks: [{id: 9, key:'z'}]})
    expect(recordStore.mocks.find(9).key).toBe('z')
