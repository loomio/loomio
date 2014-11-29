angular.module('loomioApp').factory 'RecordStore', () ->
  class RecordStore
    constructor: (db) ->
      @db = db
      @collectionNames = []

    addRecordsInterface: (recordsInterfaceClass) ->
      name = recordsInterfaceClass.model.plural
      @[name] = new recordsInterfaceClass(@)
      @collectionNames.push name

    import: (data) ->
      _.each @collectionNames, (name) =>
        if data[name]?
          _.each data[name], (record_data) =>
            @[name].new(record_data)
