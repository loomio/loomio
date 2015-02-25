angular.module('loomioApp').factory 'RecordStore', () ->
  class RecordStore
    constructor: (db) ->
      @db = db
      @collectionNames = []

    addRecordsInterface: (recordsInterfaceClass) ->
      recordsInterface = new recordsInterfaceClass(@)
      name = recordsInterface.model.plural
      @[_.camelCase(name)] = recordsInterface
      @collectionNames.push name

    import: (data) ->
      _.each @collectionNames, (name) =>
        snakeName = _.snakeCase(name)
        camelName = _.camelCase(name)
        if data[snakeName]?
          _.each data[snakeName], (recordData) =>
            @[camelName].initialize(recordData)
      data
