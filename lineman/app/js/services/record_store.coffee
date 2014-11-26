angular.module('loomioApp').factory 'RecordStore', (CollectionWrapper) ->
  class RecordStore
    constructor: (db) ->
      @db = db
      @collectionNames = []

    addCollection: (model) ->
      unwrappedCollection = @db.addCollection(model.plural)
      collection = @[model.plural] = new CollectionWrapper(@, unwrappedCollection, model)
      @collectionNames.push model.plural
      collection

    import: (data) ->
      _.each @collectionNames, (collectionName) =>
        if data[collectionName]?
          _.each data[collectionName], (record_data) =>
            @[collectionName].new(record_data)
