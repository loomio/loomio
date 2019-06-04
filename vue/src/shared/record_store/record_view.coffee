export default class RecordView
  collectionNames: []
  name: "unnamedView"

  constructor: ({name, recordStore, collections,  query}) ->
    @name = name
    @recordStore = recordStore
    @collectionNames = collections
    @query = query
    @query(@recordStore)
